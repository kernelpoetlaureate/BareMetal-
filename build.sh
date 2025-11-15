#!/bin/bash

echo "Building OS image..."

# Clean previous builds
rm -f boot.bin kernel.o kernel.bin os-image.bin floppy.img

# Compile the bootloader
nasm -f bin boot.asm -o boot.bin
if [ $? -ne 0 ]; then
    echo "Bootloader compilation failed!"
    exit 1
fi

# Compile the C kernel with proper flags to avoid PIC
gcc -m32 -ffreestanding -fno-pie -fno-pic -c kernel.c -o kernel.o
if [ $? -ne 0 ]; then
    echo "Kernel compilation failed!"
    exit 1
fi

# Link the kernel
ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary
if [ $? -ne 0 ]; then
    echo "Kernel linking failed!"
    exit 1
fi

# Check kernel size
if [ -f kernel.bin ]; then
    KERNEL_SIZE=$(stat -c%s kernel.bin 2>/dev/null || stat -f%z kernel.bin 2>/dev/null)
    SECTORS_NEEDED=$(( (KERNEL_SIZE + 511) / 512 ))
    echo "Kernel size: $KERNEL_SIZE bytes ($SECTORS_NEEDED sectors)"
else
    echo "Error: kernel.bin not created!"
    exit 1
fi

# Combine bootloader and kernel into final image
cat boot.bin kernel.bin > os-image.bin

# Create a 1.44MB floppy image
dd if=/dev/zero of=floppy.img bs=512 count=2880 status=none
dd if=os-image.bin of=floppy.img conv=notrunc status=none

echo ""
echo "Build complete!"
echo "Run with: qemu-system-i386 -fda floppy.img"
echo "Or with format specified: qemu-system-i386 -drive format=raw,file=floppy.img"