#PURPOSE - Given a number, this program computes the
#          factorial
#

#This program shows how to call a function recursively.

 .section data

#This program has no global data

 .section .text

 .globl _start
 .globl factorial   #this is unneeded unless we want to share this
                    #function among other programs.

_start:
 pushl          $4                          #factorial takes one argument
 call           factorial
 addl           $4,             %esp        #scrubs the parameter that was pushed
                                            #on the stack
 movl           %eax,           %ebx        #factorial returns the answer in %eax,
                                            #we want it in %ebx to send out as the exit
                                            #status
 movl           $1,             %eax        #exitfn
 int            $0x80


 .type factorial,@function
factorial:
 pushl          %ebp                        #standard function stuff,
                                            #we have to restore %ebp to its prior state
                                            #before returning, so we push it to the stack.
 movl           %esp,           %ebp        #we dont want to modify the stack pointer
 movl           8(%ebp),        %eax        #This moves the first argument to %eax
                                            #4(%ebp) holds the return address,
                                            #8(%ebp) holds the first param
 cmpl           $1,             %eax        #if 1, we're done.
 je             end_factorial
 decl           %eax                        #decrement
 pushl          %eax                        #push the arg...
 call           factorial
 movl           8(%ebp),        %ebx        #%eax has the return value,
                                            #so we reload our parameter into %ebx
 imull          %ebx,           %eax        #multiply the result in the last call
                                            #with the answer, return values go into
                                            #%eax
end_factorial:
 movl           %ebp,           %esp        #standard fn return stuff--
 popl           %ebp                        #we have to restore %ebp, %esp to where they
                                            #were before the function started
 ret
