; subroutine to print numbers
section .bss
	digit_space resb 100
	digit_space_pos resb 8

section .text
        global _start

_start:
	mov rax, 4238
	call _print_rax

	mov rax, 60
	xor rdi, rdi
	syscall

_print_rax:
	mov rcx, digit_space
	mov rbx, 10
	mov [rcx], rbx
	add rcx, 1
	mov [digit_space_pos], rcx

_print_rax_loop:
	mov rdx, 0
	mov rbx, 10
	div rbx
	push rax
	add rdx, 48

	mov rcx, [digit_space_pos]
	mov [rcx], dl
	add rcx, 1
	mov [digit_space_pos], rcx

	pop rax
	cmp rax, 0
	jne _print_rax_loop

_print_rax_loop2:
	mov rcx, [digit_space_pos]

	mov rax, 1
	mov rdi, 1
	mov rsi, rcx
	mov rdx, 1
	syscall

	mov rcx, [digit_space_pos]
	sub rcx, 1
	mov [digit_space_pos], rcx

	cmp rcx, digit_space
	jge _print_rax_loop2

	ret
