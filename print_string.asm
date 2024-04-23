; subroutine to print without knowing the lenght of the string
section .data
        text db "Hello, World! ", 10, 0
	text2 db "World?", 10, 0

section .bss
        name resb 16

section .text
        global _start

_start:
	mov rax, text
	call _print

	mov rax, text2
	call _print

	mov rax, 60
	xor rdi, rdi
	syscall

; input: rax as pointer to string
; output: print string at rax
_print:
	push rax
	mov rbx, 0

_print_loop:
	inc rax
	inc rbx
	mov cl, [rax]
	cmp cl, 0
	jne _print_loop

	mov rax, 1
	mov rdi, 1
	pop rsi
	mov rdx, rbx
	syscall 
	ret
