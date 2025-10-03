; mt19937.asm - This is a low-level implementation of the Mersenne Twister MT19937 pseudorandom number generator.
;               It is written in x86-64 assembly language and runs on Linux.
;
;               The program initializes the generator with seed 1 and calculates the first 10 pseudorandom numbers.
;               It then sends the results to standard output.
;

%define n 624             ; These values are used for the algorithm.
%define m 397             ;
%define w 32              ;
%define r 31              ;
%define UMASK 0x80000000  ;
%define LMASK 0x7FFFFFFF  ;
%define a 0x9908B0DF      ;
%define u 11              ;
%define s 7               ;
%define t 15              ;
%define l 18              ;
%define b 0x9D2C5680      ;
%define c 0xEFC60000      ;
%define f 1812433253      ;

section .data

	state_index dd 0  ; This is the current index into the state list.

	state_list times n dd 0  ; This is the state list array.

	num_decimal dd 0  ; This array stores the first 10 pseudorandom numbers.
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;
	            dd 0  ;

	num times 11 db 0  ; This array stores the ASCII conversions of the first 10 pseudorandom numbers.
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;
	    times 11 db 0  ;

section .text

	global _start

_start:

	mov eax, 1     ;
	call _mt_init  ; Initialize the state list with seed 1.

	mov rcx, 10           ; Retrieve the first 10 pseudorandom numbers
	mov rbx, num_decimal  ; and save them in the array at position num_decimal.

	_start_loop_calc:

		call _mt_get    ; Retrieve the next pseudorandom number.
		mov [rbx], r8d  ; Save it.
		add rbx, 4      ; Increment the pointer to the state list.

		loop _start_loop_calc

	mov rcx, 10           ; Each of the 10 pseudorandom numbers
	mov rax, num_decimal  ; must be converted to ASCII format.
	mov rbx, num          ; The array of ASCII strings is at position num.

	sub rax, 4   ; Initialize the pointer to the decimal number array
	sub rbx, 11  ; and the pointer to the ASCII string array.

	_start_loop_print:

		add rax, 4   ; Move to the next pseudorandom number to be converted.
		add rbx, 11  ;

		push rax  ; Save the pointer to the decimal number array.

		mov eax, [rax]      ;
		call _print_number  ; Convert the pseudorandom number to ASCII format.

		call _print  ; Print it.

		pop rax  ; Restore the pointer to the decimal number array.

		loop _start_loop_print

	mov rax, 60   ; Terminate the program.
	xor rdi, rdi  ; Set exit code 0.
	syscall

_mt_init:
	
	; EAX contains the seed

	mov ebx, state_list  ; EBX points to the current state in the state array.

	xor r8, r8  ; R8 is the state index.

	mov rcx, n  ; Fill in all n state values.

	_mt_init_loop:

		mov [ebx], eax  ; Set the state.

		inc r8  ; Increment the state index.

		dec rcx               ;
		jz _mt_init_loop_end  ; When RCX=0, all n state values have been set.

		add ebx, 4  ; Increment the state index pointer.

		mov edx, eax  ;
		shr edx, w-2  ;
		xor eax, edx  ;
		mov edx, f    ;
		mul edx       ;
		add eax, r8d  ; EAX = f * (EAX ^ (EAX >> (w-2))) + R8D

		jmp _mt_init_loop

	_mt_init_loop_end:

	mov ebx, state_index  ;
	mov [ebx], dword 0    ; Set the state index to 0.

	ret

_mt_get:

	push rcx  ; RCX is used as a loop index in the calling function. Save it.

	mov edi, [state_index]  ; EDI = index of current state

	mov esi, edi           ;
	cmp esi, n-1           ;
	jl _mt_get_1           ;
		xor esi, esi   ;
		jmp _mt_get_2  ;
	_mt_get_1:             ;
		inc esi        ;
	_mt_get_2:             ; ESI = index of state n-1 iterations before the current state (modulo n)

	mov r8, state_list  ;
	xor eax, eax        ;
	mov eax, edi        ;
	shl eax, 2          ;
	add r8, rax         ; R8 = pointer to the current state

	mov r9, state_list  ;
	xor eax, eax        ;
	mov eax, esi        ;
	shl eax, 2          ;
	add r9, rax         ; R9 = pointer to the state n-1 iterations before the current state (modulo n)

	mov r8d, [r8]    ;
	mov r10d, UMASK  ;
	and r8d, r10d    ; R8D = [R8] & UMASK

	mov r9d, [r9]    ;
	mov r11d, LMASK  ;
	and r9d, r11d    ; R9D = [R9] & LMASK

	or r8d, r9d  ; R8D |= R9D

	mov r10d, r8d        ;
	shr r10d, 1          ;
	test r8d, 1          ;
	jz _mt_get_3         ;
		xor r10d, a  ;
	_mt_get_3:           ; R10D = (R8D % 2 == 0) ? R8D / 2 : (R8D / 2) ^ a

	mov esi, edi           ;
	cmp esi, n-m           ;
	jl _mt_get_4           ;
		xor esi, esi   ;
		jmp _mt_get_5  ;
	_mt_get_4:             ;
		add esi, m     ;
	_mt_get_5:             ; ESI = index of state n-m iterations before the current state (modulo n)

	mov r8, state_list  ;
	xor eax, eax        ;
	mov eax, edi        ;
	shl eax, 2          ;
	add r8, rax         ; R8 = pointer to the current state

	mov r9, state_list  ;
	xor eax, eax        ;
	mov eax, esi        ;
	shl eax, 2          ;
	add r9, rax         ; R9 = pointer to the state n-m iterations before the current state (modulo n)

	mov r9d, [r9]  ;
	xor r9d, r10d  ;
	mov [r8], r9d  ; [R8] = [R9] ^ R10D

	cmp edi, n-1            ;
	je _mt_get_6            ;
		inc edi         ;
		jmp _mt_get_7   ;
	_mt_get_6:              ;
		xor edi, edi    ;
	_mt_get_7:              ;
	mov [state_index], edi  ; Increment and update the state index (modulo n).

	mov r8d, r9d  ;
	shr r9d, u    ;
	xor r8d, r9d  ; R8D = R9D ^ (R9D >> u)

	mov r9d, r8d  ;
	shl r9d, s    ;
	and r9d, b    ;
	xor r8d, r9d  ; R8D ^= (R8D << s) & b

	mov r9d, r8d  ;
	shl r9d, t    ;
	and r9d, c    ;
	xor r8d, r9d  ; R8D ^= (R8D << t) & c

	mov r9d, r8d  ;
	shr r9d, l    ;
	xor r8d, r9d  ; R8D ^= R8D >> l

	pop rcx  ; Restore the loop index for the calling function.

	ret
	
_print:

	push rcx  ; RCX is used as a loop index in the calling function. Save it.

	xor rax, rax  ; Print the pseudorandom number.
	inc rax       ; Set RAX = 1 (Linux system call 1).
	xor rdi, rdi  ; Set
	inc rdi       ; RDI = 1 for standard output.
	mov rsi, rbx  ; RBX points to the string to be printed.
	mov rdx, 11   ; Print at most 11 bytes.
	syscall

	pop rcx  ; Restore the loop index for the calling function.

	ret

_print_number:

	; The 32-bit decimal number to convert to ASCII is in eax
	; The ASCII string to print is at [rbx]

	push rbx  ; Save RBX.
	push rcx  ; RCX is used as a loop index in the calling function. Save it.

	mov r8, rbx  ; Initially, set R8 and R9 to both
	mov r9, rbx  ; point to the beginning of the string.

	push rax  ; Save the number to be printed.

	_print_number_loop:

		xor edx, edx  ;
		pop rax       ; Retrieve the dividend.
		mov ecx, 10   ;
		div ecx       ; Divide by 10.

		push rax  ; Save the divisor to be used as the dividend in the next iteration of the loop.

		or edx, 0x30  ; Convert the remainder to ASCII.

		mov [rbx], dl  ; Save the ASCII character.
		inc rbx        ; Increment the character position.
		inc r9         ; Increment R9 to match the current character position.

		cmp rax, 0              ; If the integer quotient is 0, then exit the loop.
		jne _print_number_loop  ;
	
	add rsp, 8  ; Realign the stack.

	mov [r9], byte 0xA  ; Insert a line feed at the end of the string.

	dec r9  ; Decrement R9. This is the end of the string representing the integer to be printed.

	_print_number_loop_swap:

		mov al, [r9]  ; Swap the characters at the beginning and end of the string.
		mov dl, [r8]  ;
		mov [r8], al  ;
		mov [r9], dl  ;

		inc r8  ; Increment R8.
		dec r9  ; Decrement R9.

		cmp r8, r9                  ; If R8 >= R9, then the swapping of characters is complete.
		jl _print_number_loop_swap  ;

	pop rcx  ; Restore the loop index for the calling function.
	pop rbx  ; Restore RBX.

	ret
