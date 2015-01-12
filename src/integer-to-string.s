#PURPOSE:   Convert an integer number to a decimal string for display:
#
#INPUT:     A buffer large enough to hold the largest possible number.
#           An integer to convert.
#
#OUTPUT:    The buffer will be overwritten with the decimal string.
#
#Variables:
#
#   %ecx - the count of characters processed
#   %eax - current value
#   %edi - holds the base (10)
#
 .equ ST_VALUE, 8
 .equ ST_BUFFER, 12

 .globl integer2string
 .type integer2string, @function
integer2string:

 #FN STARTS
 pushl  %ebp
 movl   %esp, %ebp

 #Current character count
 movl   $0, %ecx

 #move the value into position
 movl   ST_VALUE(%ebp), %eax

 #When we divide by 10, the 10
 #must be in a register or memory location.
 movl   $10, %edi

conversion_loop:
 #Divisiion is actually performed on the
 #combined %eds:%eax register, so first
 #clear out %edx...
 movl   $0, %edx

 #Divide %eds:%eax (implied) by 10.
 #Store the quotient in %eax and the remainder in %edx.
 divl   %edi

 #Quotient is in the right place.
 #%edx has the remainder, which now needs to be
 #converted into a number. So, %edx has a number that is
 #0-9, You should be also interpret this as an index on the
 #ASCII table starting from the character `0`. The ascii code for `0`
 #Plus zero is still `0` (jeez, so complicated).
 addl   $'0', %edx

 #Now we will take this value and push it on
 #the stack. This way, when we are done, we can
 #just pop off the characters one by one and they will
 #be in the right order, but we only need the byte in %dl
 #for the character.
 pushl %edx

 incl %ecx

 cmpl   $0, %eax
 je     end_conversion_loop

 jmp    conversion_loop

end_conversion_loop:
 #The string is now on the stac, if we pop it
 #off a character at a time, we can copy it into
 #the buffer and be done...

 #Get the pointer to the buffer in %edx
 movl   ST_BUFFER(%ebp), %edx

copy_reversing_loop:
 #we pushed the whole register, but we only need the last
 #byte... so we are going to pop off to the entire %eax register,
 #but then only move the small part (%al) into the character string.
 popl   %eax
 movb   %al, (%edx)
 #Decrease this so we know when we're done
 decl   %ecx
 #Increase this so that it points to the next byte
 incl   %edx

 #Check to see if we are finished
 cmpl   $0, %ecx
 #If so, jump to the end of the function
 je     end_copy_reversing_loop
 jmp    copy_reversing_loop

end_copy_reversing_loop:
 movb   $0, (%edx)
 movl   %ebp, %esp
 popl   %ebp
 ret
