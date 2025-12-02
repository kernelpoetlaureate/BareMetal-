[bits 32]
[org 0x1000]

global _start

_start:
    ; --- 1. Setup Segments ---
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, stack_top

    ; --- 2. Manual Call to clear_screen ---
    ; MECHANIC: A 'call' is just Pushing return address + Jumping
    sub esp, 4                  ; 1. Grow stack down by 4 bytes
    mov dword [esp], .ret_1     ; 2. Save the address of label .ret_1 to stack
    jmp clear_screen            ; 3. Jump to function
.ret_1:                         ; 4. This is where we come back

    ; --- 3. Manual Call to print_msg ---
    sub esp, 4
    mov dword [esp], .ret_2
    jmp print_msg
.ret_2:

    ; --- 4. Manual Call to create_tasks ---
    sub esp, 4
    mov dword [esp], .ret_3
    jmp create_tasks
.ret_3:

    ; --- 5. Manual Call to run_tasks ---
    sub esp, 4
    mov dword [esp], .ret_4
    jmp run_tasks
.ret_4:

    jmp $                       ; Hang

; ==========================================================
; TASK MANAGEMENT
; ==========================================================

create_tasks:
    ; Task A
    mov eax, task_a
    ; Manual call add_task
    sub esp, 4
    mov dword [esp], .ct_ret1
    jmp add_task
.ct_ret1:

    ; Task B
    mov eax, task_b
    sub esp, 4
    mov dword [esp], .ct_ret2
    jmp add_task
.ct_ret2:

    ; Task C
    mov eax, task_c
    sub esp, 4
    mov dword [esp], .ct_ret3
    jmp add_task
.ct_ret3:

    ; Manual RET
    mov ebx, [esp]      ; 1. Load return address from stack into EBX
    add esp, 4          ; 2. Shrink stack (pop)
    jmp ebx             ; 3. Jump back to caller

; ----------------------------------------------------------
; Add task (Input: EAX = function address)
add_task:
    mov edi, [task_count]
    shl edi, 2          ; Multiply index by 4
    add edi, tasks      ; Add base address
    mov [edi], eax      ; Store pointer
    inc dword [task_count]

    ; Manual RET
    mov ebx, [esp]      ; Read return address
    add esp, 4          ; Clear stack slot
    jmp ebx             ; Go back

; ----------------------------------------------------------
; Run tasks
run_tasks:
    xor ebx, ebx        ; Counter = 0
.loop:
    cmp ebx, [task_count]
    jge .done

    ; Calculate address of task pointer
    mov edx, ebx        ; Copy index
    shl edx, 2          ; Multiply by 4
    add edx, tasks      ; Add base
    mov eax, [edx]      ; EAX now holds the address of the function (e.g., task_a)

    ; Manual CALL to a DYNAMIC address (e.g., call eax)
    sub esp, 4              ; Make space
    mov dword [esp], .back  ; Push return label
    jmp eax                 ; Jump to the address inside EAX
.back:

    inc ebx
    jmp .loop

.done:
    ; Manual RET
    mov ebx, [esp]
    add esp, 4
    jmp ebx

; ==========================================================
; TASKS
; ==========================================================
task_a:
    mov esi, msg_a
    ; Manual call print
    sub esp, 4
    mov dword [esp], .ret
    jmp print
.ret:
    ; Manual ret
    mov ebx, [esp]
    add esp, 4
    jmp ebx

task_b:
    mov esi, msg_b
    sub esp, 4
    mov dword [esp], .ret
    jmp print
.ret:
    mov ebx, [esp]
    add esp, 4
    jmp ebx

task_c:
    mov esi, msg_c
    sub esp, 4
    mov dword [esp], .ret
    jmp print
.ret:
    mov ebx, [esp]
    add esp, 4
    jmp ebx

; ==========================================================
; SCREEN OUTPUT (Rewritten to remove REP STOSW)
; ==========================================================

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0720      ; Space + Color

.cls_loop:
    mov [edi], ax       ; Manual write to video memory
    add edi, 2          ; Next character cell
    dec ecx             ; Decrement counter
    jnz .cls_loop       ; If not zero, loop

    ; Manual RET
    mov ebx, [esp]
    add esp, 4
    jmp ebx

print_msg:
    mov esi, kernel_msg
    ; Fall through (Optimized jump)

print:
    mov edi, [cursor]
.print_loop:
    ; Manual LODSB (Load byte at ESI to AL, inc ESI)
    mov al, [esi]
    inc esi
    
    test al, al
    jz .print_done
    
    mov ah, 0x07        ; Color
    
    ; Manual STOSW (Store AX to EDI, inc EDI by 2)
    mov [edi], ax
    add edi, 2
    
    jmp .print_loop

.print_done:
    mov [cursor], edi
    
    ; Manual RET
    mov ebx, [esp]
    add esp, 4
    jmp ebx

; ==========================================================
; DATA
; ==========================================================
kernel_msg db "Kernel started!", 0
msg_a db "Task A running!", 0
msg_b db "Task B running!", 0
msg_c db "Task C running!", 0

cursor dd 0xB8000
task_count dd 0
tasks times 16 dd 0

; ==========================================================
; PADDING (Before BSS)
; ==========================================================
times (512 - (($ - $$) % 512)) db 0

; ==========================================================
; STACK
; ==========================================================
section .bss
    resb 4096
stack_top: