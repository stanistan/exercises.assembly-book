#PURPOSE:   Program to manage memory usage
#           - allocates and deallocates memory as
#             requested.
#
#NOTES:     The program using these rutines will ask for a
#           certain size of memory. We actually use more
#           than that size, but we put it at the beginning,
#           before the pointer we hand back. We add a size
#           field and an AVAILABLE/UNAVAILABLE marker.
#           So the memory looks like this:
#
# #########################################################
# #Available Marker#Size of memory#Actual memory locations#
# #########################################################
#                                 ^--Returns pointer
#                                    points here
#
#           The pointer we return only points to the actual
#           locations requested to make it easier for the
#           calling program. It also allows us to change
#           our structure without the calling program
#           having to change at all.

 .section .data

######GLOBAL VARS#######

#This points to the beginning of the memory we are managing.
heap_begin:
 .long 0
#This points to one location past the memory we are managing.
current_break:
 .long 0

######STRUCTURE INFORMATION####
 #size of the space for memory region header
 .equ HEADER_SIZE, 8
 #Location of the "available" flag in the header
 .equ HDR_AVAIL_OFFSET, 0
 #Location of the zie offset in the header
 .equ HDR_SIZE_OFFSET, 4

######CONSTANTS########
 .equ UNAVAILABLE, 0    #This is the number we will use to mark space
                        #that has been given out
 .equ AVAILABLE, 1      #This to mark space that has been returned, and
                        #is available for giving.
 .equ SYS_BRK, 45       #system call number for the break system call
 .equ LINUX_SYSCALL, 0x80

 .section .text

#######FUNCTIONS#######

 ##allocate_init##
 #PURPOSE:  call this function to initialize the functions
 #          (specifically, this sets heap_begin and current_break).
 #          This has no parameters and no return value.
 .globl allocate_init
 .type allocate_init,@function
allocate_init:
 pushl  %ebp
 movl   %esp, %ebp

 #If the brk system call is called with 0 in %ebx,
 #it returns the last valid usable address.
 movl   $SYS_BRK, %eax
 movl   $0, %ebx
 int    $LINUX_SYSCALL

 incl   %eax                #%eax now has the lsat valid address,
                            #and we want the memory address after that
 movl   %eax, current_break #store the current break
 movl   %eax, heap_begin    #store the current break as the first address.
                            #This will cause hte allocate function to get
                            #more moemory from Linux the first time it is run.

 movl   %ebp, %esp
 popl   %ebp
 ret
#########END

 ##allocate##
 #PUPOSE:   This function is used to grab a section of memory.
 #          It checks to see if there are any free blocks, and if not,
 #          asks Linux for a new one.
 #
 #PARAMS:   This function has one parameter - the size of the memory block
 #          we want to allocate.
 #
 #RETURN VALUE:
 #          Returns the address of the allocated memory into %eax.
 #          If there is no memory available, it returns 0.
 #
 #######PROCESSING#####
 #Variables used:
 #
 #  %ecx - hold the size of the requested memory (first/only param)
 #  %eax - current memory region being examined
 #  %ebx - current break position
 #  %edx - size of the current memory region
 #
 #We scan through each memory region starting with
 #heap_begin. Look at the size of each one, and if it has been
 #allocated. If it's big enough for the requested size & is available,
 #grab that one. If we can't find a region large enough, ask Linux for more
 #memory. In that scenario, we move current_break up.

 .globl allocate
 .type allocate,@function
 .equ ST_MEM_SIZE, 8 #stack position of the mem size to allocate
allocate:
 pushl  %ebp
 movl   %esp, %ebp

 movl   ST_MEM_SIZE(%ebp), %ecx #%ecx holds the size we are looking for
                                #the first param
 movl   heap_begin, %eax        #current search location
 movl   current_break, %ebx     #current break

alloc_loop_begin:
 cmpl   %ebx, %eax              #need more mem if these are equal.
 je     move_break

 #grab the size of this memory
 movl   HDR_SIZE_OFFSET(%eax), %edx
 #if the space is unavailable, go th
 cmpl   $UNAVAILABLE, HDR_SIZE_OFFSET(%eax)
 je     next_location

 cmpl   %edx, %ecx              #if the space is availalbe
 jle    allocate_here           #compare the size to the needed size.
                                #if it's big enough, go.

next_location:
 addl   $HEADER_SIZE, %eax      #The total size of the memory region
 addl   %edx, %eax              #is the sum of the size requested
                                #(currently stored in %edx), plus
                                #another 8 buytes for the header,
                                #(4 for the flag, and 4 for the size of the
                                #region). So, adding %edx and $8
                                #to %eax will get the address of the next
                                #memory region.
 jmp    alloc_loop_begin        #-next location

allocate_here:
 movl   $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 addl   $HEADER_SIZE, %eax      #move %eax past the header to the usable memory.
                                #, this is the pointer that we want to return.
 movl   %ebp, %esp              #and return the fn
 popl   %ebp
 ret

move_break:                     #this label means that we have exhausted
                                #all available moemory, and need to ask for more.
                                #%ebx holds the current endpoint of the data,
                                #and %ecx holds its size.
                                #
                                #we need to increase %ebx to where we _want_
                                #memory to end.
 addl   $HEADER_SIZE, %ebx      #so we add space for the headers to the structure
 addl   %ecx, %ebx              #add space to the break for the data requested

                                #now its time to ask linux for more memory

 pushl  %eax
 pushl  %ecx
 pushl  %ebx
 movl   $SYS_BRK, %eax
 int    $LINUX_SYSCALL          #inuder nomral conditions, this should return
                                #the new break in %eax, which will either be 0
                                #if it fails, or it will be equal to or larger
                                #than what we asked for. We dont care in this
                                #program where it actually sets the break as
                                #%eax isn't 0, we don't care.
 cmpl   $0, %eax
 je     error

 popl   %ebx
 popl   %ecx
 popl   %eax

 #save this memory as UNavailable, since we're about togive it away
 movl   $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
 #set the size of the memory
 movl   %ecx, HDR_SIZE_OFFSET(%eax)

 addl   $HEADER_SIZE, %eax
 movl   %ebx, current_break
 movl   %ebp, %esp
 popl   %ebp
 ret

error:
 movl   $0, %eax
 movl   %ebp, %esp
 popl   %ebp
 ret
############END

 ##deallocate##
 #PURPOSE:  The porpose of this function is to give back a region of memory
 #          to the pool after we're done using it.
 #
 #PARAMS:   The only parameter is the address of the memory we want to return
 #          To the memory pool.
 #
 #RETURN VALUE:
 #          There is no return value.
 #
 #PROCESSING:
 #          If you remember, we actulaly hand the program
 #          the start of the memory that they can use, which is 8
 #          sotrage locations after the actual start of the memory region.
 #          All we have to do is go back 8 locations and mark that
 #          memory as available,
 #          so that the allocate function knows it can use it.
 .globl deallocate
 .type deallocate,@function
 .equ ST_MEMORY_SEG, 4
deallocate:
 #since the function is simple,
 #we don't need any of the fancy function stuff.
 #
 #get the mory address of the memory to free,
 #normally this is at 8(%esp), but since we didn't push %ebp
 #or move %esp, we can do 4(%esp)
 movl   ST_MEMORY_SEG(%esp), %eax
 subl   $HEADER_SIZE, %eax
 movl   $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
 ret
##########END
