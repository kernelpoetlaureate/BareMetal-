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


; ============================================
; MEMORY ALLOCATOR
; ============================================

; Simple bump allocator
; ECX = size in bytes
; Returns: EAX = address (or 0 if failed)
malloc:
    mov eax, [heap_current]
    mov ebx, eax
    add ebx, ecx
    cmp ebx, [heap_end]
    jg .failed
    
    mov [heap_current], ebx
    ret
.failed:
    xor eax, eax
    ret
; ============================================
; DATA SECTION
; ============================================

msg_welcome db 'Welcome to Kernel v0.1', 0

; Heap boundaries
heap_start dd 0x100000      ; 1 MB
heap_current dd 0x100000
heap_end dd 0x400000        ; 4 MB limit


; Optional: Add more functions below
times 512-($-$$) db 0  ; Padding if you want alignment
