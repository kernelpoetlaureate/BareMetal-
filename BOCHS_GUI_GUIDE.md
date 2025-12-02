# Bochs GUI Guide for WSL2

## ✅ Setup Complete!

You now have Bochs running with GUI support in WSL2 using:
- **Display**: X11 (via WSLg)
- **GUI Debugger**: Enabled with `gui_debug` option
- **Sound**: Disabled (to prevent ALSA errors)

## Running Bochs with GUI

### Quick Start
```bash
bochs -f bochsrc.txt -q
```

### With Debugger
```bash
bochs -f bochsrc.txt
```
(This will show the configuration interface first)

## GUI Features

### Main Window
- **VGA Display**: Shows your bootloader/kernel output
- **Status Bar**: Shows emulation speed and status

### GUI Debugger Features (with `gui_debug` option)
When you run Bochs with `gui_debug`, you get:
- **Control buttons**: Start, Stop, Step, Continue
- **Register view**: See CPU registers in real-time
- **Memory view**: Inspect memory contents
- **Breakpoint controls**: Set/remove breakpoints visually

## Alternative GUI Options

If you want to try different GUIs, edit `bochsrc.txt` line 18:

### 1. **X11 with GUI Debugger** (Current - Recommended)
```ini
display_library: x, options="gui_debug"
```

### 2. **Plain X11** (Simple, stable)
```ini
display_library: x
```

### 3. **wxWidgets** (Full-featured, if installed)
```ini
display_library: wx
```

### 4. **SDL2** (Modern, but may crash in WSL2)
```ini
display_library: sdl2
```

### 5. **RFB/VNC** (Remote access)
```ini
display_library: rfb
```

## Debugging Tips

### Magic Breakpoint
In your assembly code, use:
```asm
xchg bx, bx  ; This triggers a breakpoint in Bochs
```

### Bochs Debugger Commands
When Bochs stops at a breakpoint, you can use:
- `c` - Continue execution
- `s` - Step one instruction
- `r` - Show registers
- `x /10 0x7c00` - Examine 10 bytes at address 0x7c00
- `info break` - List breakpoints
- `q` - Quit

### Enable Internal Debugger
To start Bochs with the command-line debugger:
```bash
bochs -f bochsrc.txt -q -debugger
```

## Troubleshooting

### GUI doesn't appear
1. Check DISPLAY variable: `echo $DISPLAY` (should show `:0`)
2. Ensure WSLg is working: `xclock` (should show a clock window)

### Segmentation Fault
- Make sure `sound: driver=dummy` is in your config
- Try switching to plain X11: `display_library: x`

### Slow Performance
- Reduce memory: Change `megs: 32` to `megs: 16`
- Disable logging: Comment out `log: bochs.log`

## Current Configuration Summary

```ini
Memory: 32 MB
Display: X11 with GUI debugger
Sound: Disabled (dummy driver)
Boot: Hard disk (os-image.bin)
Magic Breakpoints: Enabled
```

## Next Steps

1. **Run your kernel**: `bochs -f bochsrc.txt -q`
2. **Try the debugger**: Press Ctrl+C in the terminal to break into debugger
3. **Set breakpoints**: Use `xchg bx, bx` in your assembly code
4. **Explore GUI**: Click around the debugger interface

Enjoy debugging your kernel! 🚀
