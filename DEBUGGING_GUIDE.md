# 🎯 Modern OS Debugging Guide

Your OS development environment is now configured with **professional-grade debugging tools**!

## 🚀 Quick Start

### Method 1: VS Code Debugging (⭐ RECOMMENDED)

This is the **modern, visual way** to debug your OS:

1. **Install the C/C++ Extension** (one-time setup):
   - Open VS Code
   - Press `Ctrl+Shift+X` (Extensions)
   - Search for "C/C++" by Microsoft
   - Click **Install**

2. **Start Debugging**:
   - Press `F5` in VS Code
   - QEMU will launch automatically in debug mode
   - Your code will pause at the bootloader entry point (`0x7c00`)

3. **Debug Features**:
   - ✅ **Breakpoints**: Click the gutter (left of line numbers) to set breakpoints
   - ✅ **Step Through**: Use F10 (step over) and F11 (step into)
   - ✅ **Watch Registers**: See CPU registers in the left panel
   - ✅ **Memory View**: Inspect memory addresses
   - ✅ **Call Stack**: View the execution stack

### Method 2: Terminal with GDB Dashboard (🎨 Cyberpunk Style)

For a beautiful terminal-based debugging experience:

```bash
./run.sh dashboard
```

This gives you a **color-coded, split-pane terminal UI** showing:
- 📊 Registers (real-time)
- 📝 Assembly code
- 🔍 Memory view
- 📚 Stack trace

### Method 3: Normal QEMU (No Debugging)

Just run your OS without debugging:

```bash
./run.sh qemu
# or simply:
./run.sh
```

### Method 4: Manual GDB Connection

Start QEMU in debug mode, then connect manually:

```bash
# Terminal 1:
./run.sh debug

# Terminal 2:
gdb -ex "target remote localhost:1234" \
    -ex "set architecture i8086" \
    -ex "set disassembly-flavor intel" \
    -ex "break *0x7c00" \
    -ex "continue"
```

---

## 🛠️ Available Commands

| Command | Description |
|---------|-------------|
| `./run.sh` | Build and run QEMU (normal mode) |
| `./run.sh qemu` | Same as above |
| `./run.sh debug` | Start QEMU waiting for VS Code debugger |
| `./run.sh vscode` | Same as `debug` |
| `./run.sh dashboard` | Launch with GDB Dashboard (terminal UI) |
| `./run.sh bochs` | Use Bochs emulator with GDB |

---

## 📍 Important Memory Addresses

| Address | Description |
|---------|-------------|
| `0x7c00` | Bootloader entry point (BIOS loads here) |
| `0x7e00` | Kernel entry point (adjust based on your code) |
| `0x9000` | Stack location (if you set it up) |
| `0xb8000` | VGA text mode video memory |

---

## 🎓 GDB Commands Cheat Sheet

When debugging in GDB:

```gdb
# Execution Control
break *0x7c00          # Set breakpoint at address
continue               # Continue execution
stepi                  # Step one instruction
nexti                  # Step over (skip calls)

# Inspection
info registers         # Show all registers
print $eax             # Print EAX register value
x/10i $pc              # Examine 10 instructions at PC
x/16xb 0x7c00          # Examine 16 bytes at 0x7c00 (hex)
x/s 0xb8000            # Examine string at VGA memory

# Architecture
set architecture i8086          # 16-bit real mode
set architecture i386           # 32-bit protected mode
set disassembly-flavor intel    # Intel syntax

# Display
layout asm             # Show assembly layout
layout regs            # Show registers layout
refresh                # Refresh the display
```

---

## 🔧 Troubleshooting

### VS Code shows "Debug type not recognized"
**Solution**: Install the **C/C++ extension** by Microsoft
1. Press `Ctrl+Shift+X`
2. Search "C/C++"
3. Install the one by Microsoft

### QEMU window appears but stays black
**Solution**: This is normal! QEMU is waiting for the debugger.
- Press `F5` in VS Code to connect

### "Connection refused" error
**Solution**: Make sure QEMU is running first
```bash
./run.sh debug    # In one terminal
# Then press F5 in VS Code
```

### GDB Dashboard not working
**Solution**: Install it manually:
```bash
wget -P ~ https://git.io/.gdbinit
pip3 install pygments
```

---

## 🎨 VS Code Tips

### Set Conditional Breakpoints
1. Right-click on a breakpoint
2. Select "Edit Breakpoint"
3. Add condition (e.g., `$eax == 0x10`)

### Watch Expressions
1. Open "Watch" panel (left sidebar)
2. Add expressions like `$eax`, `$esp`, etc.

### Memory View
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "View Memory"
3. Enter address (e.g., `0x7c00`)

---

## 📚 Recommended Workflow

1. **Write code** in `boot.asm` or `kernel.asm`
2. **Press F5** in VS Code
3. **Set breakpoints** at critical sections
4. **Step through** your code with F10/F11
5. **Watch registers** to see state changes
6. **Fix bugs** and repeat!

---

## 🌟 Pro Tips

- Use **Intel syntax** for assembly (already configured)
- Set breakpoints at **interrupt handlers** to catch errors
- Watch the **flags register** to debug conditional jumps
- Use **memory view** to inspect the stack
- Enable **guest_errors** in QEMU to catch CPU exceptions

---

## 📖 Further Reading

- [OSDev Wiki](https://wiki.osdev.org/)
- [GDB Documentation](https://sourceware.org/gdb/documentation/)
- [QEMU Documentation](https://www.qemu.org/docs/master/)

---

**Happy OS Development! 🚀**
