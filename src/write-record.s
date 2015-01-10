
 .include "linux.s"
 .include "record-def.s"
#PURPOSE:   This function writes a record to the given
#           file descriptor.
#
#INPUT:     The file descriptor and a buffer.
#
#OUTPUT:    This function produces a status code.
#
#STACK LOCAL VARIABLES
 .equ ST_WRITE_BUFFER, 8
 .equ ST_FILEDES, 12
 .section .text
 .globl write_record
 .type write_record, @function
write_record:
 pushl   %ebp
 movl    %esp,                  %ebp

 pushl   %ebx
 movl    $SYS_WRITE,            %eax
 movl    ST_FILEDES(%ebp),      %ebx
 movl    ST_WRITE_BUFFER(%ebp), %ecx
 movl    $RECORD_SIZE,          %edx
 int     $LINUX_SYSCALL
 popl    %ebx
 movl    %ebp,                  %esp
 popl    %ebp
 ret

 .include "record-def.s"
 .include "linux.s"

#PURPOSE:   This function reads a record from the file
#           descriptor.
#
#INPUT:     The file descriptor and a buffer
#
#OUTPUT:    This function write the data to the buffer and
#           returns the status code.
#
#STACK LOCAL VARIABLES
 .equ ST_READ_BUFFER, 8
 .equ ST_FILEDES, 12
 .section .text
 .globl read_record
 .type read_record, @function
read_record:
 pushl  %ebp
 movl   %esp,                   %ebp

 pushl  %ebx
 movl   ST_FILEDES(%ebp),       %ebx
 movl   ST_READ_BUFFER(%ebp),   %ecx
 movl   $RECORD_SIZE,           %edx
 movl   $SYS_READ,              %eax
 int    $LINUX_SYSCALL
 #NOTE - %eax has the return value
 #       which we give back to the calling program
 popl   %ebx
 movl   %ebp,                   %esp
 popl   %ebp
 ret
