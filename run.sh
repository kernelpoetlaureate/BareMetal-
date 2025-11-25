#!/bin/bash
set -e

rm -f *.bin *.o

# 1. Assemblieren
nasm -f bin boot.asm -o boot.bin
nasm -f elf32 kernel_entry.asm -o kernel_entry.o

# 2. Kompilieren
gcc -m32 -ffreestanding -fno-pie -c kernel.c -o kernel.o

# 3. Linken (kernel_entry MUSS zuerst kommen)
ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

# 4. Zusammenfügen
cat boot.bin kernel.bin > os-image.bin

# --- WICHTIGE ÄNDERUNG HIER ---

# Wir füllen die Datei mit Nullen auf, bis sie exakt 1.44 MB (Standard Floppy Größe) hat.
# Das verhindert jeden "Read Error" wegen fehlender Daten.
dd if=/dev/zero of=os-image.bin bs=1024 count=1440 conv=notrunc oflag=append 2>/dev/null || true

# 5. Starten (Als Floppy!)
echo "Starte QEMU im Floppy-Modus..."
# -fda zwingt QEMU, das als Diskette A: zu laden.
# Disketten haben eine einfache Geometrie, die unser boot.asm (Cylinder 0, Head 0) liebt.
qemu-system-i386 -fda os-image.bin