%include "macro_lib.inc"

; (a -- )
native "drop", drop
 add rsp, 8
 jmp next

; ( a b -- b a )
native "swap", swap
 pop rax
 pop rdx
 push rax
 push rdx 
 jmp next

; ( a -- a a )
native "dup", dup
 mov rax, [rsp]
 push rax
 jmp next

; ( a b -- [a+b] )
native "+", plus
 pop rax
 add [rsp], rax
 jmp next

; ( a b -- [a*b] )
native "*", mul
 pop rax
 pop rdx
 imul rdx
 push rax
 jmp next

; ( a b -- [a/b] )
native "/", div
 pop rcx
 pop rax
 cqo
 idiv rcx
 push rax
 jmp next

; ( a b == [a%b] )
native "%", mod
 pop rcx
 pop rax
 cqo
 idiv rcx
 push rdx
 jmp next

; ( a b -- [a-b] )
native "-", minus
 pop rax
 sub [rsp], rax
 jmp next

; ( a b -- 1/0 ) if a == b returns 1 else 0
 native "=", equals
 pop rax
 pop rdx
 cmp rax, rdx
 jne .false
 push 1
 jmp next
 .false:
 push 0
 jmp next

; ( a b -- 1/0 ) if a < b returns 1 else 0
native "<", less
 pop rax
 pop rdx
 cmp rdx, rax
 setl al
 movzx rax, al
 push rax
 jmp next

; ( a -- 1/0) if a == 0 returns 1 else 0
native "not", not
 pop rax
 test rax, rax
 setz al
 movzx rax, al
 push rax
 jmp next

; ( a b -- [a&b] ) bitwise
native "and", and
 pop rax
 and [rsp], rax
 jmp next

; ( a b -- [a|b] ) bitwise
native "or", or
 pop rax
 or [rsp], rax
 jmp next

; (a b -- [a&&b] ) logical: if a == 0 || b == 0 returns 0 else 1
native "land", land
 pop rax
 test rax, rax
 jz .false
 pop rax, rax
 jz .false
 push 1
 jmp next
 .false:
 push 0
 jmp next

; ( a b -- [a&&b] ) logical: if a==0 && b == 0 returns 0 else 1
native "lor", lor
 pop rax
 test rax, rax
 jnz .true
 pop rax
 test rax, rax
 jnz .true
 push 0
 jmp next
 .true:
 push 1
 jmp next

; ( a -- ) 
native ">r", push_r
 pop rax
 rpush rax
 jmp next
 
; ( -- a )
native "r>", pop_r
 rpop rax
 push rax
 jmp next

; ( -- a )
native "r@", get_r
 push qword [rstack]
 jmp next

; ( addr -- val )
native "@", fetch
 pop rax
 push qword [rax]
 jmp next

; ( val addr -- )
native "!", put
 pop rax
 pop rdx
 mov [rax], rdx
 jmp next

; (val addr -- )
native "c!", putchar
 pop rdx
 pop rax
 mov [rdx], al
 jmp next

; ( addr -- val )
native "c@", fetchchar
 pop rax
 movzx rax, byte [rax]
 push rax
 jmp next

; (xt -- )
native "execute", execute
 pop rax
 mov w, rax
 jmp [rax]

native "branch", branch
 mov pc, [pc]
 jmp next

native "0branch", branch0
 pop rax
 test rax, rax
 jnz .skip
 mov pc, [pc]
 jmp next
 .skip:
 add pc, 8
 jmp next

native "find", find
 mov rsi, [lastWord]

 mov rax, [state]
 test rax, rax
 jz .loop
 mov rsi, [rsi]
.loop:
 mov rdi, [rsp]
 push rsi
 add rsi, 9
 call string_equals
 pop rsi
 test rax, rax
 jnz .found

 mov rsi, [rsi]
 test rsi, rsi
 jnz .loop
;not_found:
 mov qword [rsp], 0
 jmp next
.found:
 mov [rsp], rsi
 jmp next

native "word", word
 pop rdi
 call read_word
 push rdx
 jmp next

native "number", number
 pop rdi
 call parse_int
 push rax
 push rdx
 jmp next

colon "'", tick, 1
 dq xt_inbuf
 dq xt_word
 dq xt_drop
 dq xt_inbuf
 dq xt_find, xt_dup
 branch0 .no_such_word
  dq xt_cfa
 dq xt_state, xt_fetch
 branch0 .interpret
 dq xt_lit, xt_lit
 dq xt_comma
 dq xt_comma
.interpret:
 dq xt_exit
.no_such_word:
 dq xt_inbuf, xt_prints
 dq xt_lit, word_not_exist_msg, xt_prints
 dq xt_exit

native "emit", emit
 pop rdi
 call print_char
 jmp next

colon "count", count
 dq xt_dup
.loop:
 dq xt_dup
 dq xt_fetchchar
 branch0 .exit
 dq xt_lit, 1, xt_plus
 branch .loop
.exit:
 dq xt_swap, xt_minus, xt_exit

; (str cnt -- )
colon "printc", printc
 dq xt_push_r
.loop:
 dq xt_get_r
 branch0 .exit
 dq xt_dup, xt_fetchchar, xt_emit
 dq xt_lit, 1, xt_plus
 dq xt_pop_r, xt_lit, 1, xtminus, xt_push_r
 branch .loop

.exit:
 dq xt_pop_r, xt_drop, xt_drop, xt_exit

colon "prints", prints
 dq xt_dup, xt_count, xt_printc, xt_exit

;(call_num a1 a2 a3 a4 a5 a6 -- rax rdx)
native "syscall", syscall
 pop r9
 pop r8
 pop r10
 pop rdx
 pop rsi
 pop rdi
 pop rax
 syscall
 push rax
 push rdx
 jmp next

colon "bye", bye
 dq xt_lit, 60
 dq xt_lit, 0
 dq xt_lit, 0
 dq xt_lit, 0
 dq xt_lit, 0
 dq xt_lit, 0
 dq xt_lit, 0
 dq xt_syscall

native "cfa", cfa
 pop rsi
 add rsi, 9
.loop:
 mov al, [rsi]
 test al, al
 jz .end
 inc rsi
 jmp .loop
.end:
 add rsi, 2
 push rsi
 jmp next

section .data
 stackBase: dq 0

native "lit", lit
 push qword [pc]
 add pc, 8
 jmp next

native ",", comma
 mov rax, [curWord]
 pop qword [rax]
 add qword [curWord], 8
 jmp next
 
const inbuf, inputBuf

const state, state

const in_fd, in_fd
const mem, userMem
const dp, memPtr
const here, [curWord]

;to initialize
native "init", init
 mov qword [state], 0
 mov rstack, rstackStr
 mov pc, interpreter_stub
 cmp qword [stackBase], 0
 je .first
 mov rsp, [stack_base]
 jmp next
 .first:
 mov [stack_base], rsp
 jmp next

native "exit", exit
 rpop pc
 jmp next

section .rodata
interpreter_stub:
 dq xt_lit, 0
 dq xt_interpret_fd
 dq xt_bye

; (fd -- )
colon "interpret-fd", interpret_fd
 dq xt_lit, in_fd, xt_fetch, xt_push_r
 dq xt_lit, in_fd
 dq xt_put
 .loop:
 dq xt_inbuf, xt_word
 branch0 .end_of_input

 dq xt_inbuf
 dq xt_interpret

 branch .loop

 .end_of_input:
 dq xt_pop_r
 dq xt_lit, in_fd, xt_put
 dq xt_exit

colon "interpret", interpret
.start:
 dq xt_dup, xt_find

 dq xt_dup
 branch0 .number
 dq xt_cfa

 dq xt_state, xt_fetch
 branch0 .interpreting

 dq xt_dup
 dq xt_lit, 1, xt_minus, xt_fetchchar, xt_not
 branch0 .interpreting

 dq xt_swap, xt_drop
 dq xt_comma
 dq xt_exit

 .interpreting:
 dq xt_swap, xt_drop
 dq xt_comma
 dq xt_exit

 .number
 dq xt_drop, xt_dup
 dq xt_number
 branch0 .no_word

 dq xt_swap, xt_drop
 dq xt_state, xt_fetch
 branch0 .exit

 dq xt_here, xt_lit, 8, xt_minus, xt_fetch

 dq xt_dup
 dq xt_lit, xt_branch0
 dq xt_equals, xt_not
 branch0 .is_branch

 dq xt_dup
 dq xt_lit, xt_branch
 dq xt_equals, xt_not
 branch0 .is_branch

 dq xt_lit, xt_lit, xt_comma

.is_branch:
 dq xt_drop
 dq xt_comma
 dq xt_exit

.no_word:
 dq xt_drop
 dq xt_prints
 dq xt_lit, word_not_exist_msg, xt_prints
.exit:
 dq xt_exit
