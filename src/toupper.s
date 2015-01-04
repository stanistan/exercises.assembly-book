#PURPOSE:       This program converts an input file
#               to an output file with all letters
#               converted to uppercase.
#
#PROCESSING:    1) Open the input file
#               2) Open the output file
#               3) While we're not at the end of the file
#                   a) read part of the file into our memory buffer
#                   b) go through each byte of memory
#                       if the byte is lowercase, convert it to uppercase
#                   c) write the memory buffer to the output file.

 .section .data

######CONSTANTS######

 #system call numbers
 .equ SYS_OPEN, 5
 .equ SYS_WRITE, 4
 .equ SYS_READ, 3
 .equ SYS_CLOSE, 6
 .equ SYS_EXIT, 1

 #options for open
 #look at /usr/include/asm/fcntl.h for
 #varius values. Can be combined by adding or ORing them.
 #This is discussed later.
 .equ O_RDONLY, 0
 .equ O_CREAT_WRONGLY_TRUNC, 03101

 #standard file descriptors
 .equ STDIN, 0
 .equ STDOUT, 1
 .equ STDERR, 2

 #system call interrupt
 .equ LINUX_SYSCALL, 0x80

 .equ END_OF_FILE, 0        #This is the return valu eof read which means we've
                            #hit the end of the file.

 .equ NUMBER_ARGUMENTS, 2

 .section .bss
 #BUFFER - this is where the data is loaded into
 #         from the data file and written from into
 #         the output file. Should never exceed 16k
 #         for "various reason." ??what
 .equ BUFFER_SIZE, 500
 .lcomm BUFFER_DATA, BUFFER_SIZE

 .section .text

 #STACK POSITIONS
 .equ ST_SIZE_RESERVE, 8
 .equ ST_FD_IN, -4
 .equ ST_FD_OUT, -8
 .equ ST_ARGC, 0        #num args
 .equ ST_ARGV_0, 4      #prog name
 .equ ST_ARGV_1, 8      #input file name
 .equ ST_ARGV_2, 12     #output file name

 .globl _start
_start:
 ###INITIALIZE PROGRAM###
 #save the stack pointer
 movl   %esp,                   %ebp

 #Allocate space for our file descriptors
 #on the stack
 subl   $ST_SIZE_RESERVE,       %esp

open_files:
open_fd_in:
 ###OPEN INPUT FILE####
 #open syscall
 movl   $SYS_OPEN,              %eax
 movl   ST_ARGV_1(%ebp),        %ebx    #input filename into %ebx.
 movl   $O_RDONLY,              %ecx
 movl   $0666,                  %edx
 int    $LINUX_SYSCALL

store_fd_in:
 #save the given file descriptor
 movl   %eax,                   ST_FD_IN(%ebp)

open_fd_out:
 movl   $SYS_OPEN,              %eax
 movl   ST_ARGV_2(%ebp),        %ebx
 movl   $O_CREAT_WRONGLY_TRUNC, %ecx
 movl   $0666,                  %edx
 int    $LINUX_SYSCALL

store_fd_out:
 movl   %eax,                   ST_FD_OUT(%ebp)

###MAIN LOOP###
read_loop_begin:

 ###read a block from the input file###
 movl   $SYS_READ,              %eax
 movl   ST_FD_IN(%ebp),         %ebx
 movl   $BUFFER_DATA,           %ecx
 movl   $BUFFER_SIZE,           %edx    #size we ask for
 int    $LINUX_SYSCALL

 #check to see if we've hit the EOF marker
 cmpl   $END_OF_FILE,           %eax    #%eax will have the size of the data
                                        #in the buffer
 jle    end_loop

continue_read_loop:
 pushl  $BUFFER_DATA                    #location of the buffer
 pushl  %eax                            #size of the buffer
 call   convert_to_upper
 popl   %eax                            #get the size back
 addl   $4,                     %esp    #restore %esp

 ###write the block out to the output file
 movl   %eax,                   %edx
 movl   $SYS_WRITE,             %eax
 movl   ST_FD_OUT(%ebp),        %ebx
 movl   $BUFFER_DATA,           %ecx
 int    $LINUX_SYSCALL

 #continue
 jmp    read_loop_begin

end_loop:
 #close out file
 movl   $SYS_CLOSE,             %eax
 movl   ST_FD_OUT(%ebp),        %ebx
 int    $LINUX_SYSCALL
 #close in file
 movl   $SYS_CLOSE,             %eax
 movl   ST_FD_OUT(%ebp),        %ebx
 int    $LINUX_SYSCALL
 #exit
 movl   $SYS_EXIT,              %eax
 movl   $0,                     %ebx
 int    $LINUX_SYSCALL

#PURPOSE:   fn converts to uppercase for a block.
#
#INPUT:     First param is the location of the block of memory to convert
#           Second param is the length of the buffer
#
#OUTPUT:    Fn overwrites the buffer with the upper-casified version.
#
#VARIABLES:
#           %eax - beginning of buffer
#           %ebx - length
#           %edi - current offset
#           %cl  - current byte being examined.
#

 ###CONSTANTS####
 .equ LOWERCASE_A, 'a'
 .equ LOWERCASE_Z, 'z'
 .equ UPPER_CONVERSION, 'A' - 'a'

 ###STACK STUFF###
 .equ ST_BUFFER_LEN, 8
 .equ ST_BUFFER, 12

convert_to_upper:
 pushl  %ebp
 movl   %esp, %ebp

 #set up the vars
 movl   ST_BUFFER(%ebp),        %eax
 movl   ST_BUFFER_LEN(%ebp),    %ebx
 movl   $0,                     %edi

 #if the buffer is 0 length
 #leave
 cmpl   $0,                     %ebx
 je     end_convert_loop

convert_loop:
 #current byte
 movb   (%eax,%edi,1),          %cl
 #next byte iff not in between these two
 cmpb   $LOWERCASE_A,           %cl
 jl     next_byte
 cmpb   $LOWERCASE_Z,           %cl
 jg     next_byte
 #convert
 addb   $UPPER_CONVERSION,      %cl
 movb   %cl,                    (%eax,%edi,1)
next_byte:
 incl   %edi
 cmpl   %edi,                   %ebx
 jne    convert_loop
end_convert_loop:
 movl   %ebp,                   %esp
 popl   %ebp
 ret
