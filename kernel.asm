; kernel.asm - Minimal Multitasking Kernel
[bits 32]
[org 0x1000]

global _start

_start:
    ; 1. Setup Segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, stack_a_top   ; Use our static stack for Task A

    call kernel_main
    jmp $

; ============================================
; MAIN KERNEL LOGIC
; ============================================
kernel_main:
    ; Initialize the screen
    call clear_screen

    ; Create Task B (Pass function pointer and stack top)
    mov ebx, task_b_entry
    mov ecx, stack_b_top
    call create_task

    ; We are now "Task A". Let's loop and yield.
.loop_a:
    mov edi, 0xB8000        ; Top-left corner
    mov byte [edi], 'A'     ; Print 'A'
    mov byte [edi+1], 0x0F
    
    call delay              ; Slow down so we can see it
    call yield              ; Switch to Task B
    jmp .loop_a

; ============================================
; TASK B LOGIC
; ============================================
task_b_entry:
.loop_b:
    mov edi, 0xB809E        ; A bit further down screen
    mov byte [edi], 'B'     ; Print 'B'
    mov byte [edi+1], 0x0E  ; Yellow color
    
    call delay
    call yield              ; Switch back to Task A
    jmp .loop_b

; ============================================
; MULTITASKING CORE (The Magic)
; ============================================
current_esp dd 0           ; Storage for current task's ESP
next_esp    dd 0           ; Storage for next task's ESP

; INPUT: EBX = Function Entry, ECX = Stack Top
create_task:
    mov esi, ecx           ; Go to top of new stack
    
    ; Emulate what 'yield' expects to pop off the stack
    sub esi, 4
    mov [esi], ebx         ; Return Address (EIP)
    sub esi, 4
    mov dword [esi], 0x202 ; EFLAGS (Interrupts enabled)
    sub esi, 32            ; Allocate space for pushad (8 regs * 4 bytes)
    
    mov [next_esp], esi    ; Save this ready-to-go stack pointer
    ret

; Switch execution between Task A and Task B
yield:
    pushad                 ; Save general registers
    pushfd                 ; Save flags

    mov [current_esp], esp ; Save current task's stack position
    
    ; SWAP logic: Swap current_esp and next_esp values
    mov eax, [next_esp]
    mov edx, [current_esp]
    mov [current_esp], eax ; Prepare for next swap
    mov [next_esp], edx    ; Prepare for next swap
    
    mov esp, eax           ; LOAD the other task's stack
    
    popfd                  ; Restore flags
    popad                  ; Restore general registers
    ret                    ; Returns into the OTHER task!

; ============================================
; UTILS & DATA
; ============================================
delay:                     ; Simple waste-time loop
    mov ecx, 0xFFFFFF
.wait: loop .wait
    ret

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0720         ; Black space
    rep stosw
    ret

; ============================================
; PADDING (Fixes the Bochs Error)
; ============================================
; This calculates how many bytes are needed to reach the next 512-byte boundary
; and fills them with zeros.
times (512 - (($ - $$) % 512)) db 0

; Stacks (Static allocation for simplicity)
section .bss
    resb 4096              ; 4KB Padding
stack_a_top:
    resb 4096              ; 4KB Padding
stack_b_top: