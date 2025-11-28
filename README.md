# BareMetal x86 Kernel

A minimal bare-metal x86 operating system kernel written entirely in **pure Assembly (NASM)**. This project demonstrates the fundamentals of OS development, including bootloader creation, disk loading, and kernel initialization - all without using C.

## Project Overview
This is a simple educational operating system that boots from scratch, loads a kernel from disk, and executes assembly code to display text on screen. The entire system runs without any operating system underneath - directly on the hardware (or emulator).

## Project Structure

```
nasmkernel/
├── boot.asm            # 16-bit bootloader (512 bytes)
├── kernel.asm          # Pure assembly kernel (32-bit)
├── memalloc.asm        # Memory allocator module
├── build.sh            # Build script
├── run.sh              # Run script with QEMU
├── boot.bin            # Compiled bootloader (generated)
├── kernel.bin          # Compiled kernel (generated)
└── os-image.bin        # Final bootable OS image (generated)
```

## Components

### 1. Bootloader (`boot.asm`)

The bootloader is a 512-byte program that:
- Runs in 16-bit real mode
- Saves the boot drive number from BIOS
- Sets up a stack at `0x7c00`
- Loads 15 sectors from disk (the kernel) to memory address `0x1000`
- Uses BIOS interrupt `0x13` for disk I/O
- Includes debug output ('S' for start, 'K' for kernel loaded, 'E' for error)
- Jumps to the loaded kernel at `0x1000`

**Key Features:**
- Boot signature: `0xaa55`
- Load address: `0x7c00` (standard BIOS location)
- Kernel load address: `0x1000`
- Sectors loaded: 15

### 2. Kernel (`kernel.asm`)

A pure assembly kernel that:
- Runs in 32-bit protected mode
- Initializes segment registers (DS, ES, SS)
- Sets up stack at `0x90000`
- Directly accesses VGA text mode video memory at `0xB8000`
- Includes a simple bump allocator for memory management
- Displays characters on screen using direct memory writes

**Features:**
- Pure assembly - no C dependencies
- Memory allocator with heap management (1MB - 4MB range)
- Direct hardware access
- Modular design for easy expansion

### 3. Memory Allocator (`memalloc.asm`)

Simple bump allocator implementation:
- Heap starts at `0x100000` (1 MB)
- Heap limit at `0x400000` (4 MB)
- `malloc` function takes size in ECX, returns pointer in EAX
- Returns 0 on allocation failure

## Building and Running

### Prerequisites

- **NASM** (Netwide Assembler) - for assembling `.asm` files
- **QEMU** - x86 emulator (`qemu-system-i386` or `qemu-system-x86_64`)

Install on Debian/Ubuntu:
```bash
sudo apt-get install nasm qemu-system-x86
```

### Build and Run

#### Option 1: Using `build.sh`
```bash
chmod +x build.sh
./build.sh
```

This script:
1. Assembles the bootloader to raw binary
2. Assembles the kernel to raw binary
3. Concatenates bootloader and kernel into `os-image.bin`

#### Option 2: Using `run.sh`
```bash
chmod +x run.sh
./run.sh
```

This script builds the OS image and launches it in QEMU.

### Manual Build Steps

```bash
# 1. Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# 2. Assemble kernel
nasm -f bin kernel.asm -o kernel.bin

# 3. Create OS image
cat boot.bin kernel.bin > os-image.bin

# 4. Run with QEMU
qemu-system-i386 -fda os-image.bin
# or
qemu-system-x86_64 -drive format=raw,file=os-image.bin
```

## Technical Details

### Memory Layout

| Address Range | Purpose |
|--------------|---------|
| `0x0000 - 0x03FF` | Interrupt Vector Table (IVT) |
| `0x0400 - 0x04FF` | BIOS Data Area |
| `0x0500 - 0x7BFF` | Free memory |
| `0x7C00 - 0x7DFF` | Bootloader (512 bytes) |
| `0x7E00 - 0x0FFFF` | Stack (grows down) |
| `0x1000 - ...` | Kernel code and data |
| `0x90000` | Kernel stack (in protected mode) |
| `0xB8000 - 0xBFFFF` | VGA text mode video memory |
| `0x100000 - 0x400000` | Heap (managed by allocator) |

### Boot Process

1. **BIOS POST** - Hardware initialization
2. **BIOS Boot** - Loads first sector (bootloader) from disk to `0x7c00`
3. **Bootloader Execution:**
   - Saves boot drive number
   - Sets up stack
   - Loads kernel from disk sectors 2-16 to `0x1000`
   - Jumps to kernel entry
4. **Kernel Execution:**
   - Initializes segment registers
   - Sets up stack
   - Runs kernel code
   - Displays output to VGA memory

### Assembly Directives Explained

- `[org 0x7c00]`: Origin address where bootloader is loaded
- `[org 0x1000]`: Origin address where kernel is loaded
- `[bits 16]`: Generate 16-bit code (real mode)
- `[bits 32]`: Generate 32-bit code (protected mode)
- `times N db 0`: Repeat padding N times
- `dw 0xaa55`: Boot signature (little-endian)

### Debug Markers

The system outputs debug characters to help track boot progress:

| Character | Meaning | Location |
|-----------|---------|----------|
| S | Start - Bootloader running | `boot.asm` |
| K | Kernel loaded from disk | `boot.asm` |
| E | Error during disk read | `boot.asm` |
| d | Kernel running (or custom char) | `kernel.asm` |

## Troubleshooting

### Common Issues

**Problem:** "Booting from Hard Disk..." but nothing happens
- **Solution:** Ensure boot signature `0xaa55` is present at bytes 510-511

**Problem:** Disk read errors
- **Solution:** Verify the OS image contains both bootloader and kernel

**Problem:** Only seeing 'S' or 'SK' but no kernel output
- **Solution:** Check that kernel is assembled with `[org 0x1000]` and loaded to correct address

**Problem:** Kernel displays wrong characters
- **Solution:** Ensure kernel is in 32-bit mode and VGA memory address is `0xB8000`

### Debugging Tips

1. **Check boot signature:** `xxd boot.bin | tail -1` should show `aa55` at the end
2. **Verify kernel size:** `ls -lh kernel.bin` - should be reasonable size
3. **Inspect OS image:** `xxd os-image.bin | head -20` to see bootloader code
4. **Use QEMU monitor:** Press `Ctrl+Alt+2` in QEMU for monitor console
5. **Enable QEMU debug:** Add `-d int,cpu_reset` to QEMU command for verbose output
6. **Check file sizes:** `ls -lh *.bin` to verify all binaries were created

## Learning Resources

This project demonstrates:
- x86 assembly programming (NASM syntax)
- BIOS interrupts and services
- Bootloader development
- Disk I/O with INT 0x13
- VGA text mode programming
- Memory-mapped I/O
- Bare-metal programming without C
- Simple memory allocation

## Next Steps

Potential enhancements:
- [ ] Add protected mode switch in bootloader
- [ ] Implement Global Descriptor Table (GDT)
- [ ] Add keyboard input handling (INT 0x16 or port I/O)
- [ ] Implement interrupt descriptor table (IDT)
- [ ] Add more VGA text functions (scrolling, colors, cursor)
- [ ] Improve memory allocator (free, realloc)
- [ ] Add string manipulation functions
- [ ] Create a simple shell
- [ ] Implement basic file system
- [ ] Add multitasking support

## Why Pure Assembly?

This project uses **pure assembly** instead of C to:
- Eliminate all dependencies on compilers and standard libraries
- Provide complete control over every instruction
- Demonstrate low-level hardware interaction
- Simplify the build process (no linking complexities)
- Serve as an educational foundation for understanding how kernels work

## License

Educational project - free to use and modify.

## Acknowledgments

Built with inspiration from OS development tutorials and bare-metal programming resources. Special thanks to the NASM and QEMU communities.

---

**Author:** Giorgi  
**Last Updated:** November 2025  
**Language:** Assembly (NASM)  
**Target:** x86 (16-bit Real Mode → 32-bit Protected Mode)

