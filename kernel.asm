; kernel.asm - Pure assembly kernel
[bits 32]               ; 32-bit protected mode
[org 0x1000]           ; Kernel loads at this address


; we are marking our territory starting from 0x1000, which is lower than 
;the address we used for boot.asm file (0x7c00),
;so our kernel file is actually loaded 27,648 bytes below the boot.asm file.
; this can be easily verified by in bochs debugger "<bochs:27> x /5000gx 0x1000"


;0x0000000000001000 <bogus+       0>:    0xc08ed88e0010b866      0xe800090000bcd08e
;0x0000000000001010 <bogus+      16>:    0xbffeeb00000002        0x47c66407c6000b80
;0x0000000000001020 <bogus+      32>:    0x1059a1c30f01  0x105d1d3bcb01c389
;0x0000000000001030 <bogus+      48>:    0x10591d89077f0000      0x6557c3c031c30000
;0x0000000000001040 <bogus+      64>:    0x6f7420656d6f636c      0x206c656e72654b20
;0x0000000000001050 <bogus+      80>:    0x10000000312e3076      0x4000000010000000
;0x0000000000001060 <bogus+      96>:    0x00000000      0x00000000
;0x0000000000001070 <bogus+     112>:    0x00000000      0x00000000
;0x0000000000001080 <bogus+     128>:    0x00000000      0x00000000
;0x0000000000001090 <bogus+     144>:    0x00000000      0x00000000

;----------------------------------------

;0x0000000000007b70 <bogus+   27504>:    0x7b8601f000000000      0x1001a431a30
;0x0000000000007b80 <bogus+   27520>:    0x3f601f000010050       0x803f62d0d7b9c
;0x0000000000007b90 <bogus+   27536>:    0x800000500f0100        0x64197bde01f003f0
;0x0000000000007ba0 <bogus+   27552>:    0x2000000000    0x7b829fc00000
;0x0000000000007bb0 <bogus+   27568>:    0x74000069187bde        0xf00000040
;0x0000000000007bc0 <bogus+   27584>:    0x3f00010001003f        0x100000000001
;0x0000000000007bd0 <bogus+   27600>:    0x00000002      0x7bfc000000000000
;0x0000000000007be0 <bogus+   27616>:    0xffac0000000092d8      0x100000807bfc0000
;0x0000000000007bf0 <bogus+   27632>:    0x7c477bfc00020080      0x7c1e0f8002060000
;0x0000000000007c00 <bogus+   27648>:    0x897c00bd7cb51688      0x168a0fb61000bbec
;0x0000000000007c10 <bogus+   27664>:    0xc7e58902ec837cb5      0xffa15eb7c1e0046
;0x0000000000007c20 <bogus+   27680>:    0x66c0200f7c951601      0x9beac0220f01c883
;0x0000000000007c30 <bogus+   27696>:    0xe58902ec8300087c      0xb5f08802b4005689
;0x0000000000007c40 <bogus+   27712>:    0x7213cd02b100b600      0xc48300568be58916
;0x0000000000007c50 <bogus+   27728>:    0x8be5890a75c63802      0xb0e6ff02c4830076
;0x0000000000007c60 <bogus+   27744>:    0x46c7e58902ec8345      0xb4feeb02eb7c6d00
;0x0000000000007c70 <bogus+   27760>:    0x768be58910cd0e        0xe6ff02c483
;0x0000000000007c80 <bogus+   27776>:    0xffff0000000000        0xffff00cf9b0000
;0x0000000000007c90 <bogus+   27792>:    0x7d001700cf930000      0x8e0010b86600007c
;0x0000000000007ca0 <bogus+   27808>:    0x8ee08ec08ed08ed8      0xec8900090000bde8
;0x0000000000007cb0 <bogus+   27824>:    0x80ffff934be9  0x00000000




global _start          ; Entry point (not needed for flat binary, but good practice)

_start:
    ; Initialize segments
    mov ax, 0x10       ; If using GDT
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000   ; Stack
    
    ; Jump to main kernel code
    call kernel_main
    jmp $              ; Hang

kernel_main:
    ; Your kernel code here
    mov edi, 0xB8000
    mov byte [edi + 0], 'd'
    mov byte [edi + 1], 0x0F
    ; ... rest of characters ...
    ret


                ; ============================================
                ; MEMORY ALLOCATOR
                ; ============================================

                ; Simple bump allocator
                ; ECX = size in bytes
                ; Returns: EAX = address (or 0 if failed)
malloc:
    mov eax, [heap_current]
    mov ebx, eax
    add ebx, ecx
    cmp ebx, [heap_end]
    jg .failed
    
    mov [heap_current], ebx
    ret
.failed:
    xor eax, eax
    ret
 
                ; ============================================
                ;    DATA SECTION
                ; ============================================

msg_welcome db 'Welcome to Kernel v0.1', 0  

                ; Heap boundaries
heap_start dd 0x100000      ; 1 MB
heap_current dd 0x100000
heap_end dd 0x400000        ; 4 MB limit


                ; Optional: Add more functions below
times 512-($-$$) db 0  ; Padding if you want alignment
                