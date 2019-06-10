

global _start
%include "lib.inc"
%include "macro.inc"

%define pc r15
%define w r14
%define rstack r13

section .text

%include "words.inc" ; already defined words

section .bss

resq 1023		; stack end
rstack_start: resq 1	; stack start

input buf: resb 1024	; buffer for text
user_dict: resq 65536	; data for user defined words

user_mem: resq 65536	; global user data

state: resq 1		; changes to 1 while compiling, defualt value is 0

section .data
last_word: dq _lw	; pointer to the last word in the dictionary
here: dq user_dict	; current position
dp: dq user_mem		; current global data pointer

section .rodata
msg_no_such_word: db ": no such word", 10, 0

section .text
next:			; next word to execute
	mov w, pc
	add pc, 8
	mov w, [w]
	jmp [w]

_start:
	jmp i_init


; SIGSEV handler


%define SA_RESTORER 		0x04000000
%define SA_SIGINFO  		0x00000004
%define __NR_rt_sigaction       0x0D
%define SIGSEGV         	0x0B
setup_trap:
                mov r10, 8
                xor rdx, rdx
                mov rsi, sa
                mov     rdi, SIGSEGV
                mov rax,__NR_rt_sigaction
                syscall
        ret

section .rodata
trapword: db "trap", 0

sa:
        .handler        dq _trap
        .flags          dq SA_RESTORER | SA_SIGINFO
        .restorer       dq 0
        .val        	dq 0

%if 0

sigcontext:
        .r8                     equ 0x00
        .r9                     equ 0x08
        .r10                    equ 0x10
        .r11                    equ 0x18
        .r12                    equ 0x20
        .r13                    equ 0x28
        .r14                    equ 0x30
        .r15                    equ 0x38
        .rdi                    equ 0x40
        .rsi                    equ 0x48
        .rbp                    equ 0x50
        .rbx                    equ 0x58
        .rdx                    equ 0x60
        .rax                    equ 0x68
        .rcx                    equ 0x70
        .rsp                    equ 0x78
        .rip                    equ 0x80
        .eflags                 equ 0x88
        .cs                     equ 0x90
        .gs                     equ 0x92
        .fs                     equ 0x94
        .__pad0                 equ 0x96
        .err                    equ 0x98
        .trapno                 equ 0xa0
        .oldmask                equ 0xa8
        .cr2                    equ 0xb0
        .fpstate                equ 0xb8
        .reserved               equ 0xc0



sigaltstack:
        .ss_sp                  equ 0x00
        .ss_flags               equ 0x08
        .ss_size                equ 0x10

sigset_t:
        .sig: 8 times ?


ucontext:
        .uc_flags                               dq      ?
        .uc_link                                dq      ?
        .uc_stack                              	sigaltstack
        .uc_mcontext                    	sigcontext
        .uc_sigmask                             sigset_t

%endif
