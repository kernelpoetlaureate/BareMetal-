;pre 0x7c00 area is just a pool of zeroes and BIOS related stuff
;it looks like this
; 0x0000000000007ba0 <bogus+     160>:    0x00000000      0x00000000
; 0x0000000000007bb0 <bogus+     176>:    0x00000000      0x00000000
; 0x0000000000007bc0 <bogus+     192>:    0x00000000      0x00000000
; 0x0000000000007bd0 <bogus+     208>:    0x00000000      0x00000000
; 0x0000000000007be0 <bogus+     224>:    0x00000000      0x00000000
; 0x0000000000007bf0 <bogus+     240>:    0x00000000      0x00000000

; the registers themselves, will contain trash values from the bios, like this :
;rax: 00000000_6000aa55 - bios checked the signature, loaded it into ax and left it there
;rbx: 00000000_00000000
;rcx: 00000000_00090000
;rdx: 00000000_00000080 - this is the 0x80 boot drive, bios set dl=0x80
;rsp: 00000000_0000ffd6
;rbp: 00000000_00000000
;rsi: 00000000_000e0000
;rdi: 00000000_0000ffac
;r8 : 00000000_00000000
;r9 : 00000000_00000000
;r10: 00000000_00000000
;r11: 00000000_00000000
;r12: 00000000_00000000
;r13: 00000000_00000000
;r14: 00000000_00000000
;r15: 00000000_00000000
;rip: 00000000_00007c00


;we start at 0x7c00, this is where we place our bootloader. this very first
;address contains the very first instructions from our code below. 
[org 0x7c00]
[bits 16]

global _start

_start:

;interestingly, the below mov instruction is the first actual instruction that exists in bootloader
;code. 0x897c00bd7cb51688 is the first instruction. which translates to "mov byte ptr ds:0x7cb5, dl ; 8816b57c"

; when bios loads the bootloader, it stores the boot drive in the dl register, in this case the value is 0x80
    mov [BOOT_DRIVE], dl ; moved 0x80 to BOOT_DRIVE



    ; --- STACK SETUP ---
    ; this stack will be used for the rest of the bootloader aka boot.asm file
    mov bp, 0x7c00
    mov sp, bp ; now stack pointer is at 0x7c00, it will never above this point


    ; --- LOAD KERNEL (Manual Function Call) ---
    mov bx, 0x1000       ; I want the data read from the disk to be written to memory starting at address 0x1000
                         ; why bx? according to the int 0x13 interrupt, bx is expected to hold the destination address
    
    
    mov dh, 15           ; Number of sectors we are planning to read

    mov dl, [BOOT_DRIVE] ; Boot drive

    sub sp, 2            ; pushing pointer down by 2 bytes, 7c00 - 2 = 7bfe, bp still points to 7c00
    mov bp, sp           ; Point BP to the new top of stack aka 7bfe

    mov word [bp], return_from_disk_load ; Save the label address here
    
    ; 2. Jump to the function
    jmp disk_load ; execution jumps to the line 103

return_from_disk_load:
    ; We are back!

    ; --- SWITCH TO PROTECTED MODE ---
    cli ; we are disabling BIOS interrupts, because they dont work in protected mode
    lgdt [gdt_descriptor]

    ; as of now cr0 is 00000000_60000010
    mov eax, cr0 ; now eax holds 00000000_60000010
    or eax, 0x1 ; now eax holds 00000000_60000011
    mov cr0, eax ; now cr0 holds 00000000_60000011 which is protected mode

    ; now we are in protected mode

;   THE PROBLEM
; the cpu is always fetching multiple bootloader instructions from memory
;even tho we are in protected mode, there are still other instructions in the pipeline
;they were prefetched and decoded with 16 bit mode in mind, so we need to reset the pipeline
;for example, the next instructions which come right after mode switching, chances are, they
;were prefetched and decoded with 16 bit mode in mind, while we wrote them with protected
;mode in mind. we need to adjust the machine state to protected mode.

    ; This flushes the pipeline.
    jmp CODE_SEG:init_pm
; we can verify whether this line worked by checking the cr0 register value with gdb.
; usually it changes from 00000000_60000010 to 00000000_60000011
;it means the flushing was successful

; ==========================================
; MANUAL FUNCTION: disk_load
; ==========================================


disk_load:
    ; == REPLACING "push dx" ==
    sub sp, 2            ; Grow stack
    mov bp, sp           ; Get pointer
    mov [bp], dx         ; Store DX manually

    ; --- BIOS INTERRUPT ---

    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    int 0x13

    ; Check carry flag (Error?)
    jc disk_error

    ; == REPLACING "pop dx" ==
    ; We need to restore DX to compare values
    mov bp, sp           ; Point to stack top
    mov dx, [bp]         ; Read value back into DX
    add sp, 2            ; Shrink stack (discard saved value)

    ; Verify sector count
    cmp dh, al
    jne disk_error

    ; == REPLACING "ret" ==
    ; 1. Read the return address from the stack
    mov bp, sp           ; Point to stack top
    mov si, [bp]         ; Load return address into SI (using SI to preserve BX/DX/AX)
    
    ; 2. Clean up the stack
    add sp, 2            ; Shrink stack
    
    ; 3. Jump to the return address
    jmp si


; ==========================================
; MANUAL FUNCTION: disk_error
; ==========================================
disk_error:
    mov al, 'E'

    ; == REPLACING "call print_char" ==
    sub sp, 2
    mov bp, sp
    mov word [bp], return_from_print
    jmp print_char

return_from_print:
    jmp $                ; Hang forever


; ==========================================
; MANUAL FUNCTION: print_char
; ==========================================
print_char:
    mov ah, 0x0e
    int 0x10

    ; == REPLACING "ret" ==
    mov bp, sp
    mov si, [bp]         ; Pop return address into SI
    add sp, 2
    jmp si               ; Jump back


; ==========================================
; DATA (GDT) - Unchanged
; ==========================================
gdt_start:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


; ==========================================
; 32-BIT PROTECTED MODE
; ==========================================
; after flushing and jumping we pick up from here

[bits 32]
init_pm:
    mov ax, DATA_SEG ;ax becomes 0x0010 and now its a selector/index
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; 32-bit Stack Setup
    mov ebp, 0x90000
    mov esp, ebp

    jmp 0x1000 ; this jumps to the kernel.asm

[bits 16]
BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xaa55
