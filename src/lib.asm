global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global string_copy
global read_word
global parse_uint
global parse_int
global exit
global print_err
global read_line

section .text 

string_length: 

	xor rax, rax 
	.loop: 
		cmp byte [rdi+rax], 0 ;check if current symbol is null-terminator 
		je .end 
		inc rax 
		jmp .loop 
	.end: 
		ret 
;rdi - pointer to string
print_string: 
	call string_length 
	mov rdx, rax 
	mov rax, 1 
	mov rsi, rdi 
	mov rdi, 1 
	syscall 
	ret 

;rdi - pointer to string
print_err:
	call string_length
        mov rdx, rax
        mov rax, 1
        mov rsi, rdi
        mov rdi, 2
        syscall
        ret

print_char: 
	push rdi 
	mov rax, 1 
	mov rdx, 1 
	mov rsi, rsp 
	pop rdi 
	mov rdi, 1 
	syscall 
	ret 

print_newline: 
	mov rdi, 10 
	call print_char 
	ret
 
print_uint: 
	xor rcx, rcx 
	mov rax, rdi 
	mov r8, 10 
	mov r9, rsp 
	dec rsp 
	mov byte[rsp], 0 

	.loop: 
		xor rdx, rdx 
		div r8 
		or rdx, 0x30 
		dec rsp 
		mov [rsp], dl 
		inc rcx 
		cmp rax, 0 
		jne .loop 

	mov rdi, rsp 
	call print_string 
	mov rsp, r9 
	ret 


print_int: 
	cmp rdi, 0 
	mov r8, rdi 
	jge .unsigned 
	mov rdi, 0x2d 
	call print_char 
	neg r8 
	mov rdi, r8 
	.unsigned: 
	call print_uint 
	ret

; rdi - pointer to string 1, rsi - pointer to string 2
; retutns: 1 if strings are equal, else 0 
string_equals: 
	.loop: 
	mov cl, [rdi] 
	cmp cl, [rsi] 
	jne .f 
	cmp cl, 0 
	je .t 
	inc rdi 
	inc rsi 
	jmp .loop 
	.f: 
		xor rax, rax 
		ret 
	.t: 
		mov rax, 1 
		ret 

read_char: 
	xor rax, rax 
	mov rdi, 0 
	push 0 
	mov rsi, rsp 
	mov rdx, 1 
	syscall 
	pop rax 
	ret

;rdi - pointer to string, rsi - pointer to buffer
string_copy:
 .copy_loop:
  mov al, byte [rdi]
  mov byte [rsi], al
  inc rdi
  inc rsi
  test al, al
  jnz .copy_loop
  ret

;rdi - pointer to string, rsi - pointer to buffer, rdx - buffer length
;returns: pointer to buffer or 0 if buffer is too short
str_copy: 
	push rsi 
	call string_length 
	cmp rax, rdx 
	jge .fail 
	.copy_loop: 
	xor rcx, rcx 
	mov cl, byte[rdi] 
	mov byte[rsi], cl 
	inc rdi 
	inc rsi 
	test cl,cl
	jnz .copy_loop 

	;return address of new string 
	pop rax 
	ret 

	;return zero if buffer is shorter than original string 
	.fail: 
		pop rax
		xor rax, rax 
		
		ret

;rdi - pointer to buffer, rsi - buffer length
;returns: rdi - pointer to buffer, or 0 if buffer didn't have enough space
read_word:
	xor r8, r8
	mov r9, rsi
	dec r9

	.firstread:
	push rdi
        call read_char
        pop rdi
        cmp al, 0x20
        je .firstread
        cmp al, 10
        je .firstread
        cmp al, 13
        je .firstread
        cmp al, 9
	je .firstread
	test al,al
	jz .done

	.write:
        mov byte [rdi+r8], al
        inc r8

	;read
	push rdi
	call read_char
	pop rdi
	cmp al, 0x20
	je .done
	cmp al, 10
	je .done
	cmp al, 13
	je .done
	cmp al, 9
	je .done
	test al,al
        jz .done

	;check
	cmp r8, r9
	je .fail

	jmp .write

	.done:
	mov byte [rdi+r8], 0
	mov rax, rdi
	mov rdx, r8
	ret

	.fail:
	xor rax, rax
	ret

	pop r9

;rdi - pointer to buffer, rsi - buffer length
;returns: rdi - pointer to buffer, or 0 if buffer didn't have enough space
read_line:
        xor r8, r8
        mov r9, rsi
        dec r9

	;skip whitespaces
        .skip:
        push rdi
        call read_char
        pop rdi
        cmp al, 0x20
        je .skip
        cmp al, 10
        je .done
        test al,al
        jz .done

        .write:
        mov byte [rdi+r8], al
        inc r8

        ;read
        push rdi
        call read_char
        pop rdi
        cmp al, 10
        je .done
        test al,al
        jz .done

        ;check
        cmp r8, r9
        je .fail

        jmp .write

        .done:
        mov byte [rdi+r8], 0
        mov rax, rdi
        mov rdx, r8
        ret

        .fail:
        xor rax, rax
        ret

        pop r9

;rdi - pointer to null-terminted string
;returns: rax - parsed int, rdx - number of digits in the int
parse_uint:
	xor rax, rax
       	mov r10, 10
	xor rcx, rcx	

	.loop:	
	mov r8b, byte [rdi+rcx]
	cmp r8b, '0'
	jl .end
	cmp r8b, '9'
	jg .end
	inc rcx
	and r8, 0x0f
	mul r10
	add rax, r8
       	jmp .loop

	.end:
	mov rdx, rcx

	ret	

;rdi - pointer to null-terminated string
;returns: rax - parsed int, rdx - number of digits in the int(including sign)
parse_int:
	xor r8,r8
	mov r11b, [rdi]
	cmp r11b, '-'
	jne .plus
	mov r8, 1
	inc rdi
	
	.plus:
	push r8
	call parse_uint
	pop r8
	and r8, r8
	jz .end
	neg rax
	inc rdx
	.end:
	ret
;rdi - exit code
exit:
	mov rax, 60
	syscall	
	ret
