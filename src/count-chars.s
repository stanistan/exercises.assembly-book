#PURPOSE:   Count hte characters until a null byte is reached.
#
#INPUT:     The address of the string
#
#OUTPUT:    Returns the count in %eax
#
#PROCESS:
#   Registers used:
#       %ecx - character count
#       %al  - current character
#       %edx - current character address

 .type count_chars, @function
 .globl count_chars

 # one param
 .equ ST_STRING_START_ADDRESS, 8
count_chars:
 pushl  %ebp
 movl   %esp, %ebp

 movl   $0, %ecx
 movl   ST_STRING_START_ADDRESS(%ebp), %edx

count_loop_begin:
 movb   (%edx), %al
 cmpb   $0, %al
 je     count_loop_end
 incl   %ecx
 incl   %edx
 jmp    count_loop_begin

count_loop_end:
 movl   %ecx, %eax
 popl   %ebp
 ret
