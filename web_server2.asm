SYS_WRITE equ 1
SYS_EXIT equ 60
SYS_SOCKET equ 41
SYS_ACCEPT equ 43
SYS_BIND equ 49
SYS_LISTEN equ 50
SYS_CLOSE equ 3

AF_INET equ 2
SOCK_STREAM equ 1
INADDR_ANY equ 0
MAX_CONN equ 5

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

%macro syscall1 2
	mov rax, %1
	mov rdi, %2
	syscall
%endmacro

%macro syscall2 3
	mov rax, %1
	mov rdi, %2
	mov rsi, %3
	syscall
%endmacro

%macro syscall3 4
	mov rax, %1
	mov rdi, %2
	mov rsi, %3
	mov rdx, %4
	syscall
%endmacro

; args: err_code
%macro exit 1 
	syscall1 SYS_EXIT, %1
%endmacro

%macro write 3
	syscall3 SYS_WRITE, %1, %2, %3
%endmacro

; args: fd, buff, count
%macro socket 3
	syscall3 SYS_SOCKET, %1, %2, %3
%endmacro

; args: sockfd, addr, addr_len
%macro bind 3
	syscall3 SYS_BIND, %1, %2, %3
%endmacro

; args: sockfd, backlog
%macro listen 2
	syscall2 SYS_LISTEN, %1, %2
%endmacro

; args: sockfd, *addr, *add_len
%macro accept 3
	syscall3 SYS_ACCEPT, %1, %2, %3
%endmacro

%macro close 1
  syscall1 SYS_CLOSE, %1
%endmacro

; struct sockaddr_in {
; 	sa_family_t    sin_family   // 16 bits
; 	in_port_t      sin_port     // 16 bits
; 	struct in_addr sin_addr     // 32 bits
; 	uint6_t        sin_zero[8]; // 64 bits // padding
; }

section .data
	sockfd dq -1 ; db = 1 byte, dw = 2 bytes, dd = 4 bytes, dq = 8 bytes
	connfd dq -1 ; 0 is a valid output so we use -1 to not accidentally a successfull result

	serv_addr.sin_family dw 0
	serv_addr.sin_port dw 0
	serv_addr.sin_addr dd 0
	serv_addr.sin_zero dq 0
	serv_addr_len equ $ - serv_addr.sin_family

	cli_addr.sin_family dw 0
	cli_addr.sin_port dw 0
	cli_addr.sin_addr dd 0
	cli_addr.sin_zero dq 0
	cli_addr_len equ $ - cli_addr.sin_family

	; messages
	start db "INFO: Starting Web Server!", 10
	start_len equ $ - start
	socket_trace_m db "INFO: Crating a socket...", 10
	socket_trace_m_len equ $ - socket_trace_m
	bind_trace_m db "INFO: Binding the socket...", 10
	bind_trace_m_len equ $ - bind_trace_m
	listen_trace_m db "INFO: Listening to the socket...", 10
	listen_trace_m_len equ $ - listen_trace_m
	accept_trace_m db "INFO: Waiting for client connections...", 10
	accept_trace_m_len equ $ - accept_trace_m
	ok_m db "INFO: OK!", 10
	ok_m_len equ $ - ok_m
	error_m db "ERROR!", 10
	error_m_len equ $ - error_m
	response db "HTTP/1.1 200 OK", 13, 10
	         db "HTTP/1.1 text/html; charset=utf-8", 13, 10
	         db "Connection: close", 13, 10
		 db 13, 10
		 db "<h1>Hello from NASM!</h1>", 10
	response_len equ $ - response
	
section .text
	global _start

_start:
	write STDOUT, start, start_len
	write STDOUT, socket_trace_m, socket_trace_m_len

	socket AF_INET, SOCK_STREAM, 0
	cmp rax, 0 ; rax holds the file descriptor after creating the socket
	jl _error
	mov qword [sockfd], rax

	write STDOUT, bind_trace_m, bind_trace_m_len
	mov word [serv_addr.sin_family], AF_INET ; 16 bit-right
	mov dword [serv_addr.sin_addr], INADDR_ANY
	mov word [serv_addr.sin_port], 33315 ;; port 9090 -> hex -> backwards
	bind [sockfd], serv_addr.sin_family, serv_addr_len
	cmp rax, 0
	jl _error

	write STDOUT, listen_trace_m, listen_trace_m_len
	listen [sockfd], MAX_CONN
	cmp rax, 0
	jl _error

	write STDOUT, accept_trace_m, accept_trace_m_len
	accept [sockfd], cli_addr.sin_family, cli_addr_len
	cmp rax, 0
	jl _error

	mov qword [connfd], rax

	write [connfd], response, response_len

	write STDOUT, ok_m, ok_m_len
	close [connfd]
	close [sockfd]
	exit 0

_error:
	write STDERR, error_m, error_m_len
	close [connfd]
	close [sockfd]
	exit 1
