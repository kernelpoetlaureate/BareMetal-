#!/bin/bash
# Assemble the bootloader
nasm -f bin boot.asm -o boot.bin

# Create a blank floppy image
dd if=/dev/zero of=floppy.img bs=512 count=2880

# Write the bootloader to the floppy image
dd if=boot.bin of=floppy.img conv=notrunc

# Run Bochs
bochs -f bochsrc.txt -q
