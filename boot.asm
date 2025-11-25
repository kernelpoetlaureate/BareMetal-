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

    ; 4. Übergabe
    jmp 0x1000

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

; Daten
BOOT_DRIVE: db 0

; Padding
times 510-($-$$) db 0
dw 0xaa55