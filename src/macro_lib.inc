; macro for native words:
%define _lw 0

%macro native 3
 section .data
 wh_ %+ %2 : dq _lw
 db 0
 db %1, 0
 db %3

 ; update ref to last word
 %define _lw wh_%+ %2

 xt_ %+ %2 : dq i_ %+ %2
 
 ; start of implementation
 section .text
 i_ %+ %2 :
%endmacro

%macro native 2
 native %1, %2, 0
%endmacro

; macro for colon words
%macro colon 3
 section .data 
 wh_ %+ %2 : dq _lw
 db 0
 db %1, 0
 db %3

 ; update ref to last word
 %define _lw wh_ %+ %2

 ; implementation start
 xt_ %+ %2 : dq i_docol
%endmacro

%macro colon 2
 colon %1, %2, 0
%endmacro

%macro rpush 1
 sub rstack, 8
 mov qword [rstack], %1
%endmacro

%macro rpop 1
 mov %1, qword[rstack]
 add rstack, 8
%endmacro

%macro branch 1
 dq xt_branch
 dq %1
%endmacro

%macro branch0 1
 dq xt_branch0
 dq %1
%endmacro

%macro const 2
 %defstr %%__cnst_str %1
 native %%__cnst_str, %1
  push qword %2
  jmp next
%endmacro
