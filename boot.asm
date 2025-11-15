[BITS 16]
[ORG 0x7C00]

; Disk load parameters
KERNEL_OFFSET equ 0x1000  ; Memory offset to load kernel
KERNEL_SECTOR equ 0x2     ; Sector where kernel starts (after boot sector)

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000        ; Set stack pointer
    
    ; CRITICAL: Save boot drive number (BIOS puts it in DL)
    mov [BOOT_DRIVE], dl
    
    ; Print loading message
    mov si, msg_loading
    call print_string
    
    ; Load kernel from disk
    mov bx, KERNEL_OFFSET ; ES:BX = where to load kernel
    mov dh, 10            ; Number of sectors to read
    mov dl, [BOOT_DRIVE]  ; Use the boot drive BIOS gave us
    
    call load_disk
    
    ; Print success message
    mov si, msg_success
    call print_string
    
    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm

; Disk load function using BIOS int 0x13
load_disk:
    push dx               ; Save drive number
    
    mov ah, 0x02          ; BIOS read sector function
    mov al, dh            ; Read DH sectors
    mov ch, 0x00          ; Cylinder 0
    mov dh, 0x00          ; Head 0
    mov cl, KERNEL_SECTOR ; Start from sector 2
    
    pop dx                ; Restore drive number to DL
    push dx
    
    int 0x13              ; BIOS interrupt
    jc disk_error         ; Jump if error (carry flag set)
    
    pop dx                ; Clean up stack
    ret

disk_error:
    mov si, error_msg
    call print_string
    ; Print error code
    mov al, ah
    call print_hex
    jmp $

print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_hex:
    pusha
    mov cx, 4             ; 4 hex digits (2 bytes)
    mov bx, ax
.hex_loop:
    rol bx, 4             ; Rotate left by 4 bits
    mov al, bl
    and al, 0x0F          ; Get lowest 4 bits
    add al, 0x30          ; Convert to ASCII
    cmp al, 0x39
    jle .print_digit
    add al, 7             ; Convert A-F
.print_digit:
    mov ah, 0x0E
    int 0x10
    loop .hex_loop
    popa
    ret

[BITS 32]
init_pm:
    ; Set up data segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Jump to our C kernel!
    call KERNEL_OFFSET
    
    ; If we return, halt
    jmp $

; Data
BOOT_DRIVE db 0
msg_loading db "Loading kernel...", 13, 10, 0
msg_success db "Kernel loaded!", 13, 10, 0
error_msg db "Disk error: 0x", 0

; GDT
gdt_start:
    dq 0x0

gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xFFFF
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

times 510-($-$$) db 0
dw 0xAA55