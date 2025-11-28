[org 0x7c00]
[bits 16]

global _start

_start:
    ; 1. WICHTIG: Laufwerksnummer retten!
    ; Das BIOS liefert die Nummer des Boot-Laufwerks in DL.
    ; Wir müssen sie speichern, bevor wir DL für andere Dinge nutzen.
    mov [BOOT_DRIVE], dl

    ; 2. Stack sicherstellen
    mov bp, 0x7c00
    mov sp, bp

    ; DEBUG: Gebe 'S' aus (Start)
    mov al, 'S'
    call print_char

    ; 3. Kernel laden
    mov bx, 0x1000      ; Zieladresse
    mov dh, 15          ; Anzahl Sektoren
    mov dl, [BOOT_DRIVE]; Hole die korrekte Laufwerksnummer zurück
    call disk_load

    ; DEBUG: Gebe 'K' aus (Kernel Loaded)
    mov al, 'K'
    call print_char

    ; 4. Switch to Protected Mode
    cli                 ; Disable interrupts
    lgdt [gdt_descriptor] ; Load GDT
    
    mov eax, cr0
    or eax, 0x1         ; Set PE (Protection Enable) bit
    mov cr0, eax
    
    ; Far jump to flush pipeline and enter 32-bit mode
    jmp CODE_SEG:init_pm

; --- Hilfsfunktion: Disk lesen ---
disk_load:
    push dx             ; Speichere DX, damit wir wissen wie viele Sektoren wir wollten
    
    mov ah, 0x02        ; BIOS Read
    mov al, dh          ; Anzahl Sektoren
    mov ch, 0x00        ; Cylinder 0
    mov dh, 0x00        ; Head 0
    mov cl, 0x02        ; Start Sector 2
    int 0x13            ; interrupt
    
    jc disk_error       ; Fehler? Springe zu Error
    
    pop dx              ; Hole ursprüngliche Anforderung zurück
    cmp dh, al          ; Haben wir so viele gelesen wie gewollt?
    jne disk_error
    ret

disk_error:
    ; DEBUG: Gebe 'E' aus (Error)
    mov al, 'E'
    call print_char
    jmp $               ; Hängenbleiben

; --- Hilfsfunktion: Zeichen drucken (BIOS Teletype) ---
print_char:
    mov ah, 0x0e        ; TTY Modus
    int 0x10
    ret

; ============ GDT (Global Descriptor Table) ============
gdt_start:
    ; Null descriptor (required)
    dd 0x0
    dd 0x0

gdt_code:
    ; Code segment descriptor
    ; base=0x0, limit=0xfffff,
    ; 1st flags: (present)1 (privilege)00 (descriptor type)1 -> 1001b
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10011010b ; 1st flags, type flags
    db 11001111b ; 2nd flags, Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)

gdt_data:
    ; Data segment descriptor
    ; Same as code segment except for the type flags:
    ; type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10010010b ; 1st flags, type flags
    db 11001111b ; 2nd flags, Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT, always one less
    dd gdt_start                 ; Start address of GDT

; Define constants for segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; ============ 32-bit Protected Mode Code ============
[bits 32]
init_pm:
    ; Update all segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Jump to kernel
    jmp 0x1000

; Daten
[bits 16]
BOOT_DRIVE: db 0

; Padding
times 510-($-$$) db 0
dw 0xaa55