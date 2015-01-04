#PURPOSE:   Simple program that exits and returns a status code back
#           to the Linux kernel
#

#INPUT:     none
#

#OUTPUT:    returns a status code. This can be viewed by typing
#
#           echo $?
#
#           after running the program.
#

#VARIABLES:
#           %eax holds the system call number
#           %ebx holds the return status
#
 .section data

 .section .text
 .globl _start
_start:
 movl       $1, %eax
 movl       $0, %ebx
 int        $0x80
