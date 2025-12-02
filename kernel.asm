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
    mov esp, stack_top   ; Use kernel stack

    call kernel_main
    jmp $

; ============================================
; DATA SECTION
; ============================================
section .data
    ; Process table: 16 entries, each: eip(4), esp(4)
    proc_table times 16 dd 0, 0
    current_proc dd 0
    proc_count dd 0
    
    ; Messages
    msg_task1 db "Task A running!", 0
    msg_task2 db "Task B running!", 0
    msg_task3 db "Task C running!", 0

; ============================================
; MAIN KERNEL LOGIC
; ============================================
kernel_main:
    ; Initialize the screen
    call clear_screen
    
    ; Print kernel message
    mov esi, kernel_msg
    call print_string
    
    ; Create 3 example tasks
    mov eax, task_a
    call make_proc
    
    mov eax, task_b
    call make_proc
    
    mov eax, task_c
    call make_proc
    
    ; Run all tasks (simple round-robin)
    call run_all_tasks
    
    ; Done
    mov esi, done_msg
    call print_string
    
    jmp $  ; Halt

; ====================
; ULTRA-SIMPLE PROCESS CREATOR
; ====================

; Input: EAX = function address
; Output: EAX = process slot index (0-N)
make_proc:
    push edi
    push ebx
    
    mov edi, proc_table
    mov ecx, 16           ; Max 16 processes
.find:
    cmp dword [edi], 0    ; Check if slot free (0=eip)
    je .found
    add edi, 8            ; Each entry: eip(4), esp(4)
    loop .find
    xor eax, eax          ; Failed
    jmp .done
    
.found:
    mov [edi], eax        ; Store entry point
    
    ; Allocate unique stack for this process
    mov ebx, [proc_count]
    imul ebx, 4096        ; Each gets 4KB stack
    add ebx, stack_pool   ; Base of stack pool
    add ebx, 4096         ; Stack grows DOWN from top
    mov [edi+4], ebx      ; Store stack pointer
    
    ; Return process index
    mov eax, [proc_count]
    inc dword [proc_count]
    
.done:
    pop ebx
    pop edi
    ret

; ====================
; SIMPLE SCHEDULER
; ====================

; Run all tasks once
run_all_tasks:
    pusha
    
    mov ecx, [proc_count]
    test ecx, ecx
    jz .done
    
    mov esi, proc_table
    
.run_task:
    ; Call the task function
    mov eax, [esi]        ; Get function pointer
    call eax
    
    ; Next task
    add esi, 8
    loop .run_task
    
.done:
    popa
    ret

; ====================
; EXAMPLE TASKS
; ====================

task_a:
    push esi
    mov esi, msg_task1
    call print_string
    pop esi
    ret

task_b:
    push esi
    mov esi, msg_task2
    call print_string
    pop esi
    ret

task_c:
    push esi
    mov esi, msg_task3
    call print_string
    pop esi
    ret

; ====================
; UTILITY FUNCTIONS
; ====================

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0720         ; Grey on black space character
    rep stosw
    ret

print_string:
    push edi
    mov edi, [cursor_pos]
.print_loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x07          ; Grey on black
    stosw
    jmp .print_loop
.done:
    mov [cursor_pos], edi
    pop edi
    ret

; ====================
; DATA
; ====================
kernel_msg db "Kernel started! Creating tasks...", 0
done_msg db "All tasks completed!", 0
cursor_pos dd 0xB8000

; ============================================
; PADDING & MEMORY AREAS
; ============================================
section .bss
    ; Kernel stack
    resb 4096
stack_top:

    ; Stack pool for processes (16 * 4KB = 64KB)
    stack_pool:
    resb 65536             ; 64KB for process stacks

; Padding to reach next 512-byte boundary
times (512 - (($ - $$) % 512)) db 0