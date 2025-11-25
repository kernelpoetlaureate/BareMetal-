#!/bin/bash

# 1. Bootloader assemblieren (Raw Binary)
# Dies erzeugt genau 512 Bytes.
nasm -f bin boot.asm -o boot.bin

# 2. Kernel Entry assemblieren (ELF Format für den Linker)
nasm -f elf32 kernel_entry.asm -o kernel_entry.o

# 3. C Kernel kompilieren (Freestanding, 32-bit, keine Libs)
gcc -m32 -ffreestanding -fno-pie -c kernel.c -o kernel.o

# 4. Linken
# Wir sagen dem Linker:
# -Ttext 0x1000 : Der Code soll an Adresse 0x1000 laufen (wichtig für Pointer!)
# --oformat binary : Wir wollen keinen Linux-Header, nur Maschinencode.
# WICHTIG: kernel_entry.o MUSS vor kernel.o stehen, damit der Einstiegspunkt vorne ist!
ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

# 5. Zusammenfügen (Alles auf eine "Diskette" schreiben)
cat boot.bin kernel.bin > os-image.bin

# 6. Starten (mit QEMU)
echo "Starte QEMU..."
qemu-system-i386 -drive format=raw,file=os-image.bin