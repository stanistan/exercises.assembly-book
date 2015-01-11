
 .include "linux.s"
 .include "record-def.s"

 .section .data
file_name:
 .ascii "build/test.dat\0"
record_buffer_ptr:
 .long 0

 .section .text
 #Main program
 .globl _start
_start:
 #These are the locations on the stack
 #where we will store the input and output descriptors
 #(FYI - we coul have used memory addresses in .data section)
 .equ ST_INPUT_DESCRIPTOR, -4
 .equ ST_OUTPUT_DESCRIPTOR, -8

 movl   %esp, %ebp
 subl   $8, %esp

 call   allocate_init
 pushl  $RECORD_SIZE
 call   allocate
 movl   %eax, record_buffer_ptr

 movl   $SYS_OPEN, %eax
 movl   $file_name, %ebx
 movl   $0, %ecx
 movl   $0666, %edx
 int    $LINUX_SYSCALL

 movl   %eax, ST_INPUT_DESCRIPTOR(%ebp)

 #Even though it's a constant, we are
 #saving the output file descriptor in a
 #local var, so that we later decide that
 #it isn't always going to be STDOUT, we
 #can change it.
 movl   $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

record_read_loop:
 pushl  ST_INPUT_DESCRIPTOR(%ebp)
 pushl  record_buffer_ptr
 call   read_record
 addl   $8, %esp

 #returns the number of bytes read,
 #If it isn't the same number as we requested,
 #we're probably at EOF, but this could be an error,
 #so we GTFO.
 cmpl   $RECORD_SIZE, %eax
 jne    finished_reading

 movl   record_buffer_ptr, %eax
 addl   $RECORD_FIRSTNAME, %eax
 pushl  %eax
 call   count_chars
 addl   $4, %esp
 movl   %eax, %edx
 movl   ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
 movl   $SYS_WRITE, %eax
 movl   record_buffer_ptr, %ecx
 addl   $RECORD_FIRSTNAME, %ecx
 int    $LINUX_SYSCALL

 pushl  ST_OUTPUT_DESCRIPTOR(%ebp)
 call   write_newline
 addl   $4, %esp

 jmp    record_read_loop

finished_reading:
 pushl  record_buffer_ptr
 call   deallocate

 movl   $SYS_EXIT, %eax
 movl   $0, %ebx
 int    $LINUX_SYSCALL
