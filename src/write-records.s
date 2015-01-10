 .include "linux.s"
 .include "record-def.s"

 .section .data

 #Constant data of the records we want to write
 #Each text data item is padded to the proper length
 #with null (ie 0) bytes.

 #.rept is used to pad each item.
 #It tells the assembler to repeat hte section between
 #.rept and .endr the number of times specified.
 #This is used in this program to add extra null characters
 #add the end of each field to fill it up.
record1:
 .ascii "Fredrick\0"
 .rept 31 #padd to 40
 .byte 0
 .endr

 .ascii "Bartlett\0"
 .rept 31
 .byte 0
 .endr

 .ascii "4242 S Prairie\nTulsa, OK 55555\0"
 .rept 209
 .byte 0
 .endr

 .long 45

record2:
 .ascii "Marilyn\0"
 .rept 32
 .byte 0
 .endr

 .ascii "Taylor\0"
 .rept 33
 .byte 0
 .endr

 .ascii "2224 S Johannan St\nChicago, IL 12345\0"
 .rept 203
 .byte 0
 .endr

 .long 29

record3:
 .ascii "Derrick\0"
 .rept 32
 .byte 0
 .endr

 .ascii "McIntire\0"
 .rept 31
 .byte 0
 .endr

 .ascii "500 W Oakland\nSan Diego, CA 54321\0"
 .rept 206
 .byte 0
 .endr

 .long 36

file_name:
 .ascii "build/test.dat\0"

 .equ ST_FILE_DESCRIPTOR, -4
 .globl _start
_start:
 #copy the stack pointer to %ebp
 movl   %esp, %ebp
 #allocate space to hold the file descriptor
 subl   $4, %esp

 #open the file
 movl   $SYS_OPEN, %eax
 movl   $file_name, %ebx
 movl   $0101, %ecx     #open it/create/write
 movl   $0666, %edx     #perms
 int    $LINUX_SYSCALL

 #store the file descriptor
 movl   %eax, ST_FILE_DESCRIPTOR(%ebp)

 #write the first record
 pushl  ST_FILE_DESCRIPTOR(%ebp)
 pushl  $record1
 call   write_record
 addl   $8, %esp

 pushl  ST_FILE_DESCRIPTOR(%ebp)
 pushl  $record2
 call   write_record
 addl   $8, %esp

 pushl  ST_FILE_DESCRIPTOR(%ebp)
 pushl  $record3
 call   write_record
 addl   $8, %esp

 movl   $SYS_CLOSE, %eax
 movl   ST_FILE_DESCRIPTOR(%ebp), %ebx
 int    $LINUX_SYSCALL

 movl   $SYS_EXIT, %eax
 movl   $0, %ebx
 int    $LINUX_SYSCALL
