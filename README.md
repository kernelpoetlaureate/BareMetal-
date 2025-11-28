<<<<<<< HEAD
 BareMetal x86 Kernel

A minimal bare-metal x86 operating system kernel written in Assembly (NASM) and C. This project demonstrates the fundamentals of OS development, including bootloader creation, protected mode switching, and kernel initialization.

 Project Overview
This is a simple educational operating system that boots from scratch, loads a kernel from disk, switches to 32-bit protected mode, and executes C code to display text on screen. The entire system runs without any operating system underneath - directly on the hardware (or emulator).

 Project Structure


nasmkernel/
├── boot.asm            16-bit bootloader (512 bytes)
├── kernel_entry.asm    Kernel entry point with protected mode setup
├── kernel.c            C kernel code
├── build.sh            Build script (builds and runs)
├── run.sh              Enhanced run script with floppy disk emulation
├── test.s              GCC-generated assembly output (for debugging)
├── boot.bin            Compiled bootloader (generated)
├── kernel_entry.o      Compiled kernel entry (generated)
├── kernel.o            Compiled C kernel (generated)
├── kernel.bin          Linked kernel binary (generated)
└── os-image.bin        Final bootable OS image (generated)


 Components

 1. Bootloader (`boot.asm`)
=======
# BareMetal x86 Kernel

A minimal bare-metal x86 operating system kernel written in Assembly (NASM) and C. This project demonstrates the fundamentals of OS development, including bootloader creation, protected mode switching, and kernel initialization.

## Project Overview
This is a simple educational operating system that boots from scratch, loads a kernel from disk, switches to 32-bit protected mode, and executes C code to display text on screen. The entire system runs without any operating system underneath - directly on the hardware (or emulator).

## Project Structure

```
nasmkernel/
├── boot.asm           # 16-bit bootloader (512 bytes)
├── kernel_entry.asm   # Kernel entry point with protected mode setup
├── kernel.c           # C kernel code
├── build.sh           # Build script (builds and runs)
├── run.sh             # Enhanced run script with floppy disk emulation
├── test.s             # GCC-generated assembly output (for debugging)
├── boot.bin           # Compiled bootloader (generated)
├── kernel_entry.o     # Compiled kernel entry (generated)
├── kernel.o           # Compiled C kernel (generated)
├── kernel.bin         # Linked kernel binary (generated)
└── os-image.bin       # Final bootable OS image (generated)
```

## Components

### 1. Bootloader (`boot.asm`)
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

The bootloader is a 512-byte program that:
- Runs in 16-bit real mode
- Saves the boot drive number from BIOS
- Sets up a stack at `0x7c00`
- Loads 15 sectors from disk (the kernel) to memory address `0x1000`
- Uses BIOS interrupt `0x13` for disk I/O
- Includes debug output ('S' for start, 'K' for kernel loaded, 'E' for error)
- Jumps to the loaded kernel at `0x1000`

<<<<<<< HEAD
Key Features:
=======
**Key Features:**
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
- Boot signature: `0xaa55`
- Load address: `0x7c00` (standard BIOS location)
- Kernel load address: `0x1000`
- Sectors loaded: 15

<<<<<<< HEAD
 2. Kernel Entry (`kernel_entry.asm`)

The kernel entry point handles the transition from 16-bit real mode to 32-bit protected mode:

16-bit Real Mode Section:
=======
### 2. Kernel Entry (`kernel_entry.asm`)

The kernel entry point handles the transition from 16-bit real mode to 32-bit protected mode:

**16-bit Real Mode Section:**
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
- Displays 'A' (Assembly) to video memory as a debug marker
- Disables interrupts (`cli`)
- Loads the Global Descriptor Table (GDT)
- Enables protected mode by setting bit 0 of CR0
- Performs a far jump to flush the CPU pipeline

<<<<<<< HEAD
32-bit Protected Mode Section:
=======
**32-bit Protected Mode Section:**
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
- Sets up segment registers (DS, SS, ES, FS, GS)
- Initializes stack at `0x90000`
- Displays 'P' (Protected) to video memory
- Calls the C kernel function `kmain()`

<<<<<<< HEAD
GDT Structure:
=======
**GDT Structure:**
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
- Null descriptor (required)
- Code segment: Base 0x0, Limit 0xFFFFF, 32-bit, executable
- Data segment: Base 0x0, Limit 0xFFFFF, 32-bit, writable

<<<<<<< HEAD
 3. C Kernel (`kernel.c`)
=======
### 3. C Kernel (`kernel.c`)
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

A minimal C kernel that:
- Runs in 32-bit protected mode
- Directly accesses VGA text mode video memory at `0xB8000`
- Displays "Hallo Welt" (Hello World in German) on screen
- Uses white text on black background (color attribute `0x0F`)
- Enters an infinite loop to prevent the kernel from exiting

<<<<<<< HEAD
 Building and Running

 Prerequisites

- NASM (Netwide Assembler) - for assembling `.asm` files
- GCC - with 32-bit support (`gcc-multilib` on Debian/Ubuntu)
- LD - GNU linker with i386 support
- QEMU - x86 emulator (`qemu-system-i386`)

Install on Debian/Ubuntu:
bash
sudo apt-get install nasm gcc-multilib qemu-system-x86


 Build and Run

 Option 1: Using `build.sh`
bash
chmod +x build.sh
./build.sh

=======
## Building and Running

### Prerequisites

- **NASM** (Netwide Assembler) - for assembling `.asm` files
- **GCC** - with 32-bit support (`gcc-multilib` on Debian/Ubuntu)
- **LD** - GNU linker with i386 support
- **QEMU** - x86 emulator (`qemu-system-i386`)

Install on Debian/Ubuntu:
```bash
sudo apt-get install nasm gcc-multilib qemu-system-x86
```

### Build and Run

#### Option 1: Using `build.sh`
```bash
chmod +x build.sh
./build.sh
```
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

This script:
1. Assembles the bootloader to raw binary
2. Assembles kernel entry to ELF32 object
3. Compiles C kernel with `-m32 -ffreestanding -fno-pie`
4. Links kernel entry and C kernel to binary at `0x1000`
5. Concatenates bootloader and kernel into `os-image.bin`
6. Launches QEMU

<<<<<<< HEAD
 Option 2: Using `run.sh` 
bash
chmod +x run.sh
./run.sh

=======
#### Option 2: Using `run.sh` (Recommended)
```bash
chmod +x run.sh
./run.sh
```
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

This enhanced script:
- Cleans previous build artifacts
- Performs all build steps
- Pads the OS image to 1.44 MB (standard floppy size)
- Runs QEMU with floppy disk emulation (`-fda`)
- Prevents disk read errors with proper geometry

<<<<<<< HEAD
 Manual Build Steps

bash
 1. Assemble bootloader
nasm -f bin boot.asm -o boot.bin

 2. Assemble kernel entry
nasm -f elf32 kernel_entry.asm -o kernel_entry.o

 3. Compile C kernel
gcc -m32 -ffreestanding -fno-pie -c kernel.c -o kernel.o

 4. Link kernel (entry point must come first!)
ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

 5. Create OS image
cat boot.bin kernel.bin > os-image.bin

 6. Run with QEMU
qemu-system-i386 -fda os-image.bin


 Technical Details

 Memory Layout
=======
### Manual Build Steps

```bash
# 1. Assemble bootloader
nasm -f bin boot.asm -o boot.bin

# 2. Assemble kernel entry
nasm -f elf32 kernel_entry.asm -o kernel_entry.o

# 3. Compile C kernel
gcc -m32 -ffreestanding -fno-pie -c kernel.c -o kernel.o

# 4. Link kernel (entry point must come first!)
ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

# 5. Create OS image
cat boot.bin kernel.bin > os-image.bin

# 6. Run with QEMU
qemu-system-i386 -fda os-image.bin
```

## Technical Details

### Memory Layout
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

| Address Range | Purpose |
|--------------|---------|
| `0x0000 - 0x03FF` | Interrupt Vector Table (IVT) |
| `0x0400 - 0x04FF` | BIOS Data Area |
| `0x0500 - 0x7BFF` | Free memory |
| `0x7C00 - 0x7DFF` | Bootloader (512 bytes) |
| `0x7E00 - 0x7FFFF` | Stack grows down from here |
| `0x1000 - ...` | Kernel code and data |
| `0x90000` | Kernel stack (in protected mode) |
| `0xB8000 - 0xBFFFF` | VGA text mode video memory |

<<<<<<< HEAD
 Boot Process

1. BIOS POST - Hardware initialization
2. BIOS Boot - Loads first sector (bootloader) from disk to `0x7c00`
3. Bootloader Execution:
=======
### Boot Process

1. **BIOS POST** - Hardware initialization
2. **BIOS Boot** - Loads first sector (bootloader) from disk to `0x7c00`
3. **Bootloader Execution**:
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
   - Saves boot drive number
   - Sets up stack
   - Loads kernel from disk sectors 2-16 to `0x1000`
   - Jumps to kernel entry
<<<<<<< HEAD
4. Kernel Entry:
   - Switches from 16-bit real mode to 32-bit protected mode
   - Sets up GDT and segment registers
   - Calls C kernel
5. C Kernel:
   - Displays text to screen
   - Halts in infinite loop

 Compiler Flags Explained

- `-m32`: Generate 32-bit code
- `-ffreestanding`: Freestanding environment (no standard library)
- `-fno-pie`: Disable position-independent executable (we need fixed addresses)
- `-Ttext 0x1000`: Set text section to load at address `0x1000`
- `--oformat binary`: Output raw binary (no ELF headers)

 Debug Markers
=======
4. **Kernel Entry**:
   - Switches from 16-bit real mode to 32-bit protected mode
   - Sets up GDT and segment registers
   - Calls C kernel
5. **C Kernel**:
   - Displays text to screen
   - Halts in infinite loop

### Compiler Flags Explained

- **`-m32`**: Generate 32-bit code
- **`-ffreestanding`**: Freestanding environment (no standard library)
- **`-fno-pie`**: Disable position-independent executable (we need fixed addresses)
- **`-Ttext 0x1000`**: Set text section to load at address `0x1000`
- **`--oformat binary`**: Output raw binary (no ELF headers)

### Debug Markers
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

The system outputs debug characters to help track boot progress:

| Character | Meaning | Location |
|-----------|---------|----------|
<<<<<<< HEAD
| S | Start - Bootloader running | `boot.asm` |
| K | Kernel loaded from disk | `boot.asm` |
| E | Error during disk read | `boot.asm` |
| A | Assembly - Kernel entry (16-bit) | `kernel_entry.asm` |
| P | Protected mode active (32-bit) | `kernel_entry.asm` |
| Hallo Welt | C kernel running | `kernel.c` |

  Troubleshooting

 Common Issues

Problem: "Booting from Hard Disk..." but nothing happens
- Solution: Use `run.sh` which properly formats the image as a floppy disk

Problem: Disk read errors
- Solution: Ensure the OS image is padded to proper size (1.44 MB for floppy)

Problem: Only seeing 'S' or 'SK' but no kernel output
- Solution: Check that kernel is being loaded to correct address and linked properly

Problem: Compilation errors about 32-bit support
- Solution: Install `gcc-multilib` package

 Debugging Tips

1. Check boot signature: `xxd boot.bin | tail -1` should show `aa55` at the end
2. Verify kernel size: `ls -lh kernel.bin` - should be reasonable size
3. Inspect OS image: `xxd os-image.bin | head -20` to see bootloader code
4. Use QEMU monitor: Press `Ctrl+Alt+2` in QEMU for monitor console
5. Enable QEMU debug: Add `-d int,cpu_reset` to QEMU command for verbose output

 Learning Resources
=======
| **S** | Start - Bootloader running | `boot.asm` |
| **K** | Kernel loaded from disk | `boot.asm` |
| **E** | Error during disk read | `boot.asm` |
| **A** | Assembly - Kernel entry (16-bit) | `kernel_entry.asm` |
| **P** | Protected mode active (32-bit) | `kernel_entry.asm` |
| **Hallo Welt** | C kernel running | `kernel.c` |

##  Troubleshooting

### Common Issues

**Problem**: "Booting from Hard Disk..." but nothing happens
- **Solution**: Use `run.sh` which properly formats the image as a floppy disk

**Problem**: Disk read errors
- **Solution**: Ensure the OS image is padded to proper size (1.44 MB for floppy)

**Problem**: Only seeing 'S' or 'SK' but no kernel output
- **Solution**: Check that kernel is being loaded to correct address and linked properly

**Problem**: Compilation errors about 32-bit support
- **Solution**: Install `gcc-multilib` package

### Debugging Tips

1. **Check boot signature**: `xxd boot.bin | tail -1` should show `aa55` at the end
2. **Verify kernel size**: `ls -lh kernel.bin` - should be reasonable size
3. **Inspect OS image**: `xxd os-image.bin | head -20` to see bootloader code
4. **Use QEMU monitor**: Press `Ctrl+Alt+2` in QEMU for monitor console
5. **Enable QEMU debug**: Add `-d int,cpu_reset` to QEMU command for verbose output

## Learning Resources
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

This project demonstrates:
- x86 assembly programming (NASM syntax)
- BIOS interrupts and services
- Bootloader development
- Real mode to protected mode transition
- Global Descriptor Table (GDT) setup
- Bare-metal C programming
- Memory-mapped I/O (VGA text mode)
- Linking and binary formats

<<<<<<< HEAD
 Next Steps
=======
## Next Steps
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

Potential enhancements:
- [ ] Add keyboard input handling
- [ ] Implement interrupt descriptor table (IDT)
- [ ] Add more VGA text functions (scrolling, colors)
- [ ] Implement basic memory management
- [ ] Add support for reading/writing files
- [ ] Create a simple shell
- [ ] Switch to long mode (64-bit)
- [ ] Add multitasking support

<<<<<<< HEAD
 License

Educational project - free to use and modify.

 Acknowledgments
=======
## License

Educational project - free to use and modify.

## Acknowledgments
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)

Built with inspiration from OS development tutorials and bare-metal programming resources. Special thanks to the NASM and QEMU communities.


<<<<<<< HEAD
Author: Giorgi  
Last Updated: November 2025  
Language: Assembly (NASM), C  
Target: x86 (32-bit Protected Mode)


=======
**Author**: Giorgi  
**Last Updated**: November 2025  
**Language**: Assembly (NASM), C  
**Target**: x86 (32-bit Protected Mode)
>>>>>>> 5ad60aa (feat: Add comprehensive README.md detailing the bare-metal x86 kernel project and update generated binaries.)
