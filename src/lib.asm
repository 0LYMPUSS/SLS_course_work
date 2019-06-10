
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy
global read_line
global print_err

section .data
in_fd: dq 0

section .text

print_err:
        call string_length
        mov rdx, rax
        mov rax, 1
        mov rsi, rdi
        mov rdi, 2
        syscall
        ret

read_line:
	xor r8, r8
        mov r9, rsi
        dec r9

        .loop:
        push rdi
        call read_char
        pop rdi
        cmp al, 0x20
        je .loop
        cmp al, 0x09
        je .loop
        cmp al, 0x0d
        je .loop
        cmp al, 0x0a
        je .loop
        test al, al
        jz .loop3

        .loop2:
        mov byte [rdi + r8], al
        inc r8
        push rdi
        call read_char
        pop rdi
        cmp al, 0x0a
        je .loop3
        test al, al
        jz .loop3
        cmp r8, r9
        je .fin
        jmp .loop2

        .loop3:
        mov byte[rdi + r8], 0
        mov rax, rdi
        mov rdx, r8
        ret

        .fin:
        xor rax, rax
        ret

string_length:
	
    	xor rax, rax
    	.loop:
		cmp byte [rdi+rax], 0 	;check if current symbol is null-terminator
		je .end			
		inc rax
		jmp .loop
	.end: 
    	ret	

print_string:
    	call string_length
	mov rdx, rax
	mov rax, 1
	mov rsi, rdi
	mov rdi, 1
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

string_equals:
	.loop:
	mov cl, byte[rdi]
	cmp cl, byte[rsi]
	jne .falsee
	cmp byte[rdi], 0
	je .end
	inc rdi
	inc rsi
	jmp .loop

	.falsee:
	mov rax, 0
	ret

	.truee:
	mov rax, 1
	ret

	.end:
	cmp byte[rsi], 0
	jne .falsee
	jmp .truee

read_char:
    	xor rax, rax
	mov rdi, 0	
	push 0
	mov rsi, rsp
	mov rdx, 1
	syscall
	pop rax
    	ret 

read_word:
	xor r8, r8
	mov r9, rsi
	dec r9

	.loop:
	push rdi
	call read_char
	pop rdi
	cmp al, 0x20
	je .loop
	cmp al, 0x09
	je .loop
	cmp al, 0x0d
	je .loop
	cmp al, 0x0a
	je .loop
	test al, al
	jz .loop3

	.loop2:
	mov byte [rdi + r8], al
	inc r8
	push rdi
	call read_char
	pop rdi
	cmp al, 0x20
	je .loop3
	cmp al, 0x09
	je .loop3
	cmp al, 0x0d
	je .loop3
	cmp al, 0x0a
	je .loop3
	test al, al
	jz .loop3
	cmp r8, r9
	je .fin
	jmp .loop2

	.loop3:
	mov byte[rdi + r8], 0
	mov rax, rdi
	mov rdx, r8
	ret

	.fin:
	xor rax, rax
    	ret

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    	xor rax, rax
	xor rcx, rcx
	mov r9, 10	

	.find_int:
	mov r8b, byte[rdi+rcx]
	cmp r8b, '0'
	jl .end
	cmp r8b, '9'
	jg .end
	inc rcx
	and r8, 0xf
	mul r9
	add rax, r8
	jmp .find_int

	.end:
	mov rdx, rcx
	ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    	xor rax, rax
	
	mov r10b, byte[rdi]
	cmp r10b, '-'
	je .minus

	call parse_uint	
	ret
	
	.minus:
	inc rdi
	call parse_uint
	inc rdx
	neg rax	
    	ret 


string_copy:
	push rsi
	call string_length
	cmp rax, rdx
	jge .zero
	.copy_loop:
	xor rcx, rcx
	mov cl, byte[rdi]
	mov byte[rsi], cl
	inc rdi
	inc rsi
	test cl, cl
	jnz .copy_loop
	
	;return address to new string
	.fin:
	pop rax
	ret
	
	;return zero if buffer-size and string-size don't match
	.zero:
	pop rax
	xor rax, rax
	ret
