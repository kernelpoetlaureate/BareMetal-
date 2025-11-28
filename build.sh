#!/bin/bash

# Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# Assemble kernel (32-bit ELF or flat binary)
nasm -f bin kernel.asm -o kernel.bin

# Combine bootloader + kernel
cat boot.bin kernel.bin > os-image.bin

echo "Build complete: os-image.bin"
