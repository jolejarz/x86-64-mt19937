%define n 624
%define m 397
%define w 32
%define r 31
%define UMASK 0x80000000
%define LMASK 0x7FFFFFFF
%define a 0x9908B0DF
%define u 11
%define s 7
%define t 15
%define l 18
%define b 0x9D2C5680
%define c 0xEFC60000
%define f 1812433253

section .data

	state_index dd 0

	state_list times n dd 0

	num times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0
	    times 11 db 0

	num_decimal dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0
	            dd 0

section .text

	global _start

_start:

	mov eax, 1
	call _mt_init

	mov rcx, 10
	mov rbx, num_decimal

	_start_loop_calc:

		call _mt_get
		mov [rbx], r8d
		add rbx, 4

	loop _start_loop_calc

	mov rcx, 10
	mov rax, num_decimal
	mov rbx, num
	sub rax, 4
	sub rbx, 11

	_start_loop_print:

		add rax, 4
		add rbx, 11
		push rax
		push rcx
		push rbx
		mov eax, [rax]
		call _print_number
		pop rbx
		call _print
		pop rcx
		pop rax

	loop _start_loop_print

	mov rax, 60
	xor rdi, rdi
	syscall

_mt_init:
	
	; EAX contains the seed

	mov ebx, state_list

	mov r8, 0
	mov rcx, n
	_mt_init_loop:

		mov [ebx], eax

		inc r8
		dec rcx
		jz _mt_init_loop_end

		add ebx, 4

		mov edx, eax
		shr edx, w-2
		xor eax, edx
		mov edx, f
		mul edx
		add eax, r8d

		jmp _mt_init_loop

	_mt_init_loop_end:

	mov ebx, state_index
	mov [ebx], dword 0

	ret

_mt_get:

	push rcx

	mov edi, [state_index]
	mov esi, edi
	cmp esi, n-1
	jl _mt_get_1
		sub esi, n-1
		jmp _mt_get_2
	_mt_get_1:
		add esi, 1
	_mt_get_2:

	mov r8, state_list
	xor rax, rax
	mov eax, edi
	mov ecx, 4
	mul ecx
	add r8, rax
	mov r9, state_list
	xor rax, rax
	mov eax, esi
	mov ecx, 4
	mul ecx
	add r9, rax

	mov r8d, [r8]
	mov r10d, UMASK
	and r8d, r10d
	mov r9d, [r9]
	mov r11d, LMASK
	and r9d, r11d

	or r8d, r9d

	mov r10d, r8d
	shr r10d, 1
	test r8d, 1
	jz _mt_get_3
		xor r10d, a
	_mt_get_3:

	mov edi, [state_index]
	mov esi, edi
	cmp esi, n-m
	jl _mt_get_4
		sub esi, n-m
		jmp _mt_get_5
	_mt_get_4:
		add esi, m
	_mt_get_5:

	mov r8, state_list
	xor rax, rax
	mov eax, edi
	mov ecx, 4
	mul ecx
	add r8, rax
	mov r9, state_list
	xor rax, rax
	mov eax, esi
	mov ecx, 4
	mul ecx
	add r9, rax

	mov r9d, [r9]
	xor r9d, r10d
	mov [r8], r9d

	cmp edi, n-1
	je _mt_get_6
		inc edi
		jmp _mt_get_7
	_mt_get_6:
		xor edi, edi
	_mt_get_7:
	mov [state_index], edi

	mov r8d, r9d
	shr r9d, u
	xor r8d, r9d

	mov r9d, r8d
	shl r9d, s
	and r9d, b
	xor r8d, r9d

	mov r9d, r8d
	shl r9d, t
	and r9d, c
	xor r8d, r9d

	mov r9d, r8d
	shr r9d, l
	xor r8d, r9d

	pop rcx

	ret
	
_print:
	mov rax, 1
	mov rdi, 1
	mov rsi, rbx
	mov rdx, 11
	syscall
	ret

_print_number:
	; The 32-bit decimal number to convert to ASCII is in eax
	; The ASCII string to print is at [rbx]

	mov r8, rbx
	mov r9, rbx

	push rax

	_print_number_loop:

		xor edx, edx
		pop rax
		mov ecx, 10
		div ecx
		push rax
		add edx, 0x30
		mov [rbx], dl
		inc rbx
		inc r9
		cmp rax, 0
		jne _print_number_loop
	
	add rsp, 8
	push r9
	dec r9

	_print_number_loop_swap:

		mov al, [r9]
		mov dl, [r8]
		mov [r8], al
		mov [r9], dl
		inc r8
		dec r9
		cmp r8, r9
		jl _print_number_loop_swap

	pop r9
	mov [r9], byte 0xA

	ret
