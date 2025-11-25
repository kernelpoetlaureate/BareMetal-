[bits 16]
[extern kmain]

section .text
    global _start

_start:
    ; --- DEBUG 1: Wir sind bei 0x1000 angekommen (16-Bit) ---
    ; Wir schreiben ein 'A' (für Assembly) direkt in den Videospeicher.
    ; Im Real Mode ist der Video-Speicher bei Segment 0xB800.
    mov ax, 0xb800
    mov es, ax
    mov byte [es:0], 'A'    ; Überschreibt das 'S' vom Bootloader mit 'A'
    mov byte [es:1], 0x0f   ; Farbe Weiß auf Schwarz

    ; 1. Protected Mode vorbereiten
    cli
    lgdt [gdt_descriptor]

    ; 2. Modus wechseln
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; 3. Far Jump
    jmp CODE_SEG:init_pm

; --- GDT (Identisch wie vorher) ---
gdt_start:
    dq 0x0

gdt_code:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
init_pm:
    ; 4. Segmente setzen
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    ; --- DEBUG 2: Wir sind im Protected Mode (32-Bit) ---
    ; Im Protected Mode ist der Videospeicher linear bei 0xB8000.
    ; Wir schreiben ein 'P' (für Protected) neben das 'A'.
    mov byte [0xb8002], 'P'
    mov byte [0xb8003], 0x0f

    ; 5. C Kernel aufrufen
    call kmain
    
    jmp $