; test.asm - This program demonstrates the use of the functions in mt19937.asm.
;            It initializes the generator with seed 1 and calculates the first 10 pseudorandom numbers.
;            It then sends the results to standard output.
;

extern mt19937_init
extern mt19937_get

section .data

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

	mov eax, 1         ;
	call mt19937_init  ; Initialize the generator with seed 1.

	mov rcx, 10           ; Retrieve the first 10 pseudorandom numbers
	mov rbx, num_decimal  ; and save them in the array at position num_decimal.

	_start_loop_calc:

		call mt19937_get  ; Retrieve the next pseudorandom number.
		mov [rbx], r8d    ; Save it.
		add rbx, 4        ; Increment the pointer to the state list.

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

		mov eax, [rax]  ;
		call _convert   ; Convert the pseudorandom number to ASCII format.

		call _print  ; Print it.

		pop rax  ; Restore the pointer to the decimal number array.

		loop _start_loop_print

	mov rax, 60   ; Terminate the program.
	xor rdi, rdi  ; Set exit code 0.
	syscall

_print:

	push rcx  ; RCX is used as a loop index in the calling function. Save it.

	mov rax, 1    ; Print the pseudorandom number.
	mov rdi, 1    ; Set RDI = 1 for standard output.
	mov rsi, rbx  ; RSI points to the string to be printed.
	mov rdx, 11   ; Print at most 11 bytes.
	syscall

	pop rcx  ; Restore the loop index for the calling function.

	ret

_convert:

	; The 32-bit decimal number to convert to ASCII is in eax
	; The ASCII string to print is at [rbx]

	push rbx  ; Save RBX.
	push rcx  ; RCX is used as a loop index in the calling function. Save it.

	mov r8, rbx  ; Initially, set R8 and R9 to both
	mov r9, rbx  ; point to the beginning of the string.

	push rax  ; Save the number to be printed.

	_convert_loop:

		xor edx, edx  ;
		pop rax       ; Retrieve the dividend.
		mov ecx, 10   ;
		div ecx       ; Divide by 10.

		push rax  ; Save the divisor to be used as the dividend in the next iteration of the loop.

		or edx, 0x30  ; Convert the remainder to ASCII.

		mov [rbx], dl  ; Save the ASCII character.
		inc rbx        ; Increment the character position.
		inc r9         ; Increment R9 to match the current character position.

		cmp rax, 0         ; If the integer quotient is 0, then exit the loop.
		jne _convert_loop  ;
	
	add rsp, 8  ; Realign the stack.

	mov [r9], byte 0xA  ; Insert a line feed at the end of the string.

	dec r9  ; Decrement R9. This is the end of the string representing the integer to be printed.

	_convert_loop_swap:

		mov al, [r9]  ; Swap the characters at the beginning and end of the string.
		mov dl, [r8]  ;
		mov [r8], al  ;
		mov [r9], dl  ;

		inc r8  ; Increment R8.
		dec r9  ; Decrement R9.

		cmp r8, r9             ; If R8 >= R9, then the swapping of characters is complete.
		jl _convert_loop_swap  ;

	pop rcx  ; Restore the loop index for the calling function.
	pop rbx  ; Restore RBX.

	ret
