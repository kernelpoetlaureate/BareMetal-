; kernel.asm - Pure assembly kernel
[bits 32]               ; 32-bit protected mode
[org 0x1000]           ; Kernel loads at this address

global _start          ; Entry point (not needed for flat binary, but good practice)

_start:
    ; Initialize segments
    mov ax, 0x10       ; If using GDT
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000   ; Stack
    
    ; Jump to main kernel code
    call kernel_main
    jmp $              ; Hang

kernel_main:
    ; Your kernel code here
    mov edi, 0xB8000
    mov byte [edi + 0], 'd'
    mov byte [edi + 1], 0x0F
    ; ... rest of characters ...
    ret

; Optional: Add more functions below
times 512-($-$$) db 0  ; Padding if you want alignment
