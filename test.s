	.file	"kernel.c"
	.intel_syntax noprefix
	.text
	.section	.rodata
.LC0:
	.string	"Hallo Welt"
	.text
	.globl	kmain
	.type	kmain, @function
kmain:
	push	ebp
	mov	ebp, esp
	sub	esp, 16
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	DWORD PTR -12[ebp], 753664
	lea	eax, .LC0@GOTOFF[eax]
	mov	DWORD PTR -16[ebp], eax
	mov	DWORD PTR -4[ebp], 0
	mov	DWORD PTR -8[ebp], 0
	jmp	.L2
.L3:
	mov	edx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR -16[ebp]
	add	eax, edx
	mov	ecx, DWORD PTR -8[ebp]
	mov	edx, DWORD PTR -12[ebp]
	add	edx, ecx
	movzx	eax, BYTE PTR [eax]
	mov	BYTE PTR [edx], al
	mov	eax, DWORD PTR -8[ebp]
	lea	edx, 1[eax]
	mov	eax, DWORD PTR -12[ebp]
	add	eax, edx
	mov	BYTE PTR [eax], 15
	add	DWORD PTR -8[ebp], 2
	add	DWORD PTR -4[ebp], 1
.L2:
	mov	edx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR -16[ebp]
	add	eax, edx
	movzx	eax, BYTE PTR [eax]
	test	al, al
	jne	.L3
.L4:
	jmp	.L4
	.size	kmain, .-kmain
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
	mov	eax, DWORD PTR [esp]
	ret
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
