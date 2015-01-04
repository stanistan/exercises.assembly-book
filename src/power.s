 .section .data

 .section .text

 .globl _start
_start:
 pushl          $3
 pushl          $2
 call           power
 addl           $8,             %esp
 pushl          %eax

 pushl          $2
 pushl          $5
 call           power
 addl           $8,             %esp

 popl           %ebx

 addl           %eax,           %ebx

 movl           $1,             %eax
 int            $0x80

 .type power,@function
power:
 pushl          %ebp
 movl           %esp,           %ebp
 subl           $4,             %esp

 movl           8(%ebp),        %ebx
 movl           12(%ebp),       %ecx

 movl           %ebx,           -4(%ebp)

power_loop_start:
 cmpl           $1,             %ecx
 je             end_power
 movl           -4(%ebp),       %eax
 imull          %ebx,           %eax
 movl           %eax,           -4(%ebp)
 decl           %ecx
 jmp            power_loop_start

end_power:
 movl           -4(%ebp),       %eax
 movl           %ebp,           %esp
 popl           %ebp
 ret
