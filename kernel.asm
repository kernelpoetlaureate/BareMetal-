[bits 32]
[org 0x1000]

; Entry point
global _start
_start:
    mov ax, 0x10          ; Setup data segment
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, stack_top    ; Setup stack
    
    call clear_screen
    call print_msg        ; Print "Kernel started!"
    call create_tasks     ; Create 3 tasks
    call run_tasks        ; Run them all
    
    jmp $                 ; Hang

; ========== TASK MANAGEMENT ==========

create_tasks:
    mov eax, task_a       ; Create task A
    call add_task
    mov eax, task_b       ; Create task B
    call add_task
    mov eax, task_c       ; Create task C
    call add_task
    ret

; Add task to process table
; Input: EAX = function address
add_task:
    mov edi, [task_count]
    shl edi, 2            ; Multiply by 4 (each entry is a dword)
    add edi, tasks
    mov [edi], eax        ; Store function pointer
    inc dword [task_count]
    ret

; Run all tasks once
run_tasks:
    xor ebx, ebx          ; Counter = 0
.loop:
    cmp ebx, [task_count]
    jge .done             ; If counter >= task_count, done
    
    mov eax, [tasks + ebx*4]  ; Get task function pointer
    call eax              ; Run task
    
    inc ebx
    jmp .loop
.done:
    ret

; ========== TASKS ==========

task_a:
    mov esi, msg_a
    call print
    ret

task_b:
    mov esi, msg_b
    call print
    ret

task_c:
    mov esi, msg_c
    call print
    ret

; ========== SCREEN OUTPUT ==========

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0720        ; Space with grey on black
    rep stosw
    ret

print_msg:
    mov esi, kernel_msg
    ; Fall through to print

print:
    mov edi, [cursor]
.loop:
    lodsb                 ; Load byte from ESI
    test al, al           ; Check for null terminator
    jz .done
    mov ah, 0x07          ; Grey on black
    stosw                 ; Write to screen
    jmp .loop
.done:
    mov [cursor], edi
    ret

; ========== DATA ==========

kernel_msg db "Kernel started!", 0
msg_a db "Task A running!", 0
msg_b db "Task B running!", 0
msg_c db "Task C running!", 0

cursor dd 0xB8000
task_count dd 0
tasks times 16 dd 0       ; Space for 16 task pointers

; ========== STACK ==========

section .bss
    resb 4096
stack_top: