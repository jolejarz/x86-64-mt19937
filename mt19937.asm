; mt19937.asm - This is a low-level implementation of the Mersenne Twister MT19937 pseudorandom number generator.
;               It is written in x86-64 assembly.
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

section .text

	global mt19937_init  ; This function initializes the generator, with the seed specified in EDI.
	global mt19937_get   ; This function returns the next pseudorandom number in EAX.

mt19937_init:

	push rax
	push rbx
	push rcx
	push rdx
	push r8
	push r9

	mov eax, edi  ; EAX is the seed.
	
	mov ebx, state_list  ; EBX points to the current state in the state array.

	xor r8, r8  ; R8 is the state index.

	mov rcx, n  ; Fill in all n state values.

	mt19937_init_loop:

		mov [ebx], eax  ; Set the state.

		inc r8  ; Increment the state index.

		dec rcx                   ;
		jz mt19937_init_loop_end  ; When RCX = 0, all n state values have been set.

		add ebx, 4  ; Increment the state index pointer.

		mov edx, eax  ;
		shr edx, w-2  ;
		xor eax, edx  ;
		mov edx, f    ;
		mul edx       ;
		add eax, r8d  ; EAX = f * (EAX ^ (EAX >> (w-2))) + R8D

		jmp mt19937_init_loop

	mt19937_init_loop_end:

	mov ebx, state_index  ;
	mov [ebx], dword 0    ; Set the state index to 0.

	pop r9
	pop r8
	pop rdx
	pop rcx
	pop rbx
	pop rax

	ret

mt19937_get:

	push rcx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11

	mov edi, [state_index]  ; EDI = index of current state

	mov esi, edi           ;
	cmp esi, n-1           ;
	jl mt19937_get_1       ;
	    xor esi, esi       ;
	    jmp mt19937_get_2  ;
	mt19937_get_1:         ;
	    inc esi            ;
	mt19937_get_2:         ; ESI = index of state n-1 iterations before the current state (modulo n)

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

	mov r10d, r8d     ;
	shr r10d, 1       ;
	test r8d, 1       ;
	jz mt19937_get_3  ;
	    xor r10d, a   ;
	mt19937_get_3:    ; R10D = (R8D % 2 == 0) ? R8D / 2 : (R8D / 2) ^ a

	mov esi, edi           ;
	cmp esi, n-m           ;
	jl mt19937_get_4       ;
	    xor esi, esi       ;
	    jmp mt19937_get_5  ;
	mt19937_get_4:         ;
	    add esi, m         ;
	mt19937_get_5:         ; ESI = index of state n-m iterations before the current state (modulo n)

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
	je mt19937_get_6        ;
	    inc edi             ;
	    jmp mt19937_get_7   ;
	mt19937_get_6:          ;
	    xor edi, edi        ;
	mt19937_get_7:          ;
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

	mov eax, r8d  ; Return the next pseudorandom number.

	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rcx

	ret
