: isEven dup 2 % not ;

: rot4 >r rot r> swap ;

: isPrime dup 2 = if 1 else dup 1 swap 2 repeat dup rot dup rot % rot4 land dup rot4 rot4 dup 2 / rot 1 + dup rot > rot4 not lor until drop drop 0 > then ;

: isPrimeAllot isPrime 8 allot dup -rot ! ;

( dest source -- )
: strcp dup count 1 + 0 for dup c@ rot dup rot swap c! 1 + swap 1 + endfor drop drop ;

( str1 str2 -- res )
: concat dup  count rot dup count rot + 1 + heap-alloc dup rot dup rot swap strcp count swap dup rot + rot strcp ;

: collatz dup 1 > if  dup repeat dup 2 % not if 2 /  else 3 * 1 + endif dup dup 1 = until drop else 1 endif ;

 
