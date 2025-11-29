#!/bin/bash
set -e

# Clean previous builds
rm -f *.bin *.o

# 1. Assemble bootloader (16-bit, flat binary)
nasm -f bin boot.asm -o boot.bin

# 2. Assemble kernel (32-bit, flat binary)
nasm -f bin kernel.asm -o kernel.bin

# 3. Combine bootloader + kernel
cat boot.bin kernel.bin > os-image.bin

# 4. Pad to floppy size (1.44 MB)
dd if=/dev/zero of=os-image.bin bs=1024 count=1440 conv=notrunc oflag=append 2>/dev/null || true

# Choose emulator
if [ "$1" == "bochs" ]; then
    echo "Starting Bochs with debugger..."
    bochs -f bochsrc.txt -dbg
else
    echo "Starte QEMU im Floppy-Modus..."
    qemu-system-i386 -fda os-image.bin -d guest_errors
fi
