
 .include "linux.s"

 .section .data

tmp_buffer:
 .ascii "\0\0\0\0\0\0\0\0\0\0\0"

 .section .text
 .globl _start
_start:
 movl   %esp, %ebp

 pushl  $tmp_buffer
 pushl  $824
 call   integer2string
 addl   $8, %esp

 pushl  $tmp_buffer
 call   count_chars
 addl   $4, %esp

 movl   %eax, %edx

 movl   $SYS_WRITE, %eax
 movl   $STDOUT, %ebx
 movl   $tmp_buffer, %ecx
 int    $LINUX_SYSCALL

 pushl  $STDOUT
 call   write_newline

 movl   $SYS_EXIT, %eax
 movl   $0, %ebx
 int    $LINUX_SYSCALL
