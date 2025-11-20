#!/bin/bash
set -e  # Exit on any error

echo "=== Building Bootloader ==="
# Assemble the bootloader
nasm -f bin boot.asm -o boot.bin -l boot.lst
echo "✓ boot.bin created ($(stat -c%s boot.bin) bytes)"

echo ""
echo "=== Compiling Kernel ==="
# Compile the kernel
# -ffreestanding: standard libraries not available
# -c: compile only, don't link
# -m32: compile for 32-bit mode
# -fno-pie: disable position-independent executable
# -fno-pic: disable position-independent code
gcc -ffreestanding -m32 -fno-pie -fno-pic -c kernel.c -o kernel.o
echo "✓ kernel.o created ($(stat -c%s kernel.o) bytes)"

echo ""
echo "=== Linking Kernel ==="
# Link the kernel
# -o kernel.bin: output file
# -Ttext 0x1000: the address where our code will be loaded
# --oformat binary: output raw binary
# -m elf_i386: link for 32-bit x86
ld -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary -m elf_i386
echo "✓ kernel.bin created ($(stat -c%s kernel.bin) bytes)"

echo ""
echo "=== Creating OS Image ==="
# Concatenate bootloader and kernel
cat boot.bin kernel.bin > os-image.bin
echo "✓ os-image.bin created ($(stat -c%s os-image.bin) bytes)"

echo ""
echo "=== Creating Floppy Image ==="
# Create floppy image
dd if=/dev/zero of=floppy.img bs=512 count=2880 2>/dev/null
dd if=os-image.bin of=floppy.img conv=notrunc 2>/dev/null
echo "✓ floppy.img created"

echo ""
echo "=== Launching Bochs ==="
# Run Bochs with debugger enabled
bochs -f bochsrc.txt -q -dbg

