# Oliver Bölin & Philippe Van Daele
# Lab 3
# 2023-06-01

.data
    input_buffer:   .space 64   
    output_buffer:  .space 64
    input_offset:   .quad 0
    output_offset:  .quad 0
    max_buffer:     .quad 64    # maximum size of a 64 bit buffer
    
    #  functions for input
    .global inImage
    .global getInt
    .global getText
    .global getChar
    .global getInPos
    .global setInPos

    #  functions for output
    .global outImage
    .global putInt
    .global putText
    .global putChar
    .global getOutPos
    .global setOutPos

.text
# inmatningar
inImage:
    movq $0, input_offset       # assigns input_offset to 0
    leaq input_buffer, %rdi     # loads the address of input_buffer to %rdi, points to input_buffer
    movq $64, %rsi              # Sets the maximum characters to 64
    movq stdin, %rdx            # Gets values from stdin
    call fgets                  # calls fgets
    leaq input_offset, %rax     # loads the address of input_offset to %rax
    movq $0, %rax               # resetting %rax back to zero
    ret

getInt:
    push %r10
    push %r11 
    push %r12

_getIntGetNextValue:
    leaq input_buffer, %rax     # loads the address of input_buffer to %rax
    movq input_offset, %r10     # assigns the value of input_offset to %r10
    leaq (%rax, %r10), %rdi     # loads the current buffer position into %rdi
    movq $0, %rax               # the value
    movq $0, %r11               # the sign
    movzbq (%rdi), %r12         # Moves the byte at current buffer position into the %r12, zero-extending it to a quadword.
    cmpb $0, (%rdi)             # compares the value if it is null-terminator
    je _getIntInImage           # jump if equal
    cmpb $'\n', (%rdi)          # compares the value if it contains a newline
    je _getIntInImage           # jump if equal

_getIntCheckBlank:
    cmpb $' ', (%rdi)           # compares the binary value to see if there is a space
    jne _getIntCheckPlus        # jumps to check if plussign

    incq %rdi                   # increment %rdi by 1
    incq %r10                   # increment %r10 by 1

    jmp _getIntCheckBlank

_getIntCheckPlus:
    cmpb $'+', (%rdi)           # compare the binary value to see if there is a plus sign
    jne _getIntCheckMinus

    incq %rdi                   # increment %rdi by 1
    incq %r10                   # increment %r10 by 1

    jmp _getIntConvert

_getIntCheckMinus:
    cmpb $'-', (%rdi)           # compare the binary value to see if there is a minus sign
    jne _getIntConvert
    movq $1, %r11

    incq %rdi                   # increment %rdi by 1
    incq %r10                   # increment %r10 by 1

_getIntConvert:
    cmpb $'0', (%rdi)           # If value is less than 0 it jumps to _getIntFlag to see if minus sign was used
    jl _getIntFlag              
    cmpb $'9', (%rdi)
    jg _getIntFlag              # If more than 9 we negate the value

    movzbq (%rdi), %r12         # Moves the byte at current buffer position into the %r12, zero-extending it to a quadword.
    subq $'0', %r12             
    imulq $10, %rax
    addq %r12,%rax
    incq %rdi                   # increment %rdi by 1
    incq %r10                   # increment %r10 by 1
    incq %r12                   # increment %r12 by 1

    jmp _getIntConvert
_getIntFlag:
    cmpq $1, %r11               # Compare the value of %R11 with 1 to see if it contains a minus
    jne _getIntEnd              # Jump to lEnd if %r11 is not equal to 1
    negq %rax                   # Negate the value in the %rax register
_getIntEnd:
    movq %r10, input_offset
    pop %r10 
    pop %r11 
    pop %r12
    ret

_getIntInImage:
    pushq %rax                  # Push %rax
    call inImage                # Calls inImage to reset the buffer
    popq %rax                   # Pops %rax 
    jmp _getIntGetNextValue     

getText:
    pushq %r10                  # Push r10 into the stack
    movq $0, %r10               # Assigns %r10 with 0
    movq input_offset, %rcx     # Moves the value from input_offset to %rcx
    incq %rcx                   # skips the space that is in the buffer
    leaq input_buffer, %rax     # Loads %rax with the address from input_buffer
    movq (%rax, %rcx), %rdx     # get address of buffer and offset, put at rdx
    cmpq $0, %rdx               # check if not 0
    je inImage
_getTextLoop:
    cmpq $0, %rsi               # Check if not 0
    je _returnGetText
    movq (%rax, %rcx), %rdx     # Move the value at address (rax + rcx) to rdx register
    incq %rcx                   # Increments %rcx
    movq %rdx, (%rdi)           # Move the value of rdx to the address pointed by rdi
    incq %r10                   # Increments %r10
    cmpb $0, (%rdi)             # Compare the value at the address pointed by rdi with 0
    je _returnGetText
    decq %rsi
    incq %rdi
    jmp _getTextLoop
_returnGetText:
    movq %rcx, input_offset
    movq %r10, %rax
    popq %r10
    ret

getChar:
    pushq %rax                  
    call getInPos               # gets the position of the input_offset
    cmpq $0, %rax               # if 0, we call inImage
    je inImage
    cmpq $0, input_buffer       # if empty, we call inImage
    je inImage
    incq %rax                   # increment %rax
    movq %rax, input_offset     # Moves the offset back into input_offset
    pop %rax                    
    ret

getInPos:
    movq input_offset, %rax     # Returns the offset to %rax
    ret

setInPos:
    cmpq  $0, %rdi              # 
    jle _inPosLessThan          
    cmpq $63, %rdi
    jge inPosMoreThan
    movq %rdi, input_offset
    ret
_inPosLessThan:
    movq $0, input_offset
    ret
inPosMoreThan:
    movq $63, input_offset
    ret

# <-------------------- utmatningar -------------------->
outImage:
    movq $0, %r10
    pushq %r10
    movq $output_offset, %rax
    xor %rax, %rax              # Set rax to 0
    leaq output_buffer, %rdi
    movq $0, output_offset
    call puts
    popq %r10
    ret

putInt:
    pushq $0
    movq $10, %r10              # Set the divisor to 10
_putIntCheckNegative:
    cmpq $0, %rdi
    jl _putIntnegative
_putIntRDItoRAX:
    movq %rdi, %rax
    cmpq %r10, %rax
    jl _putIntOneDigit          # We dont divide if 0
_putIntConvert:
    cqto                 
    idivq %r10                  # %rsi % 10 (RAX = 0, RDX = 5) Signed divide %rdx:%rax by S
_putIntCheckZero:
    addq $48, %rdx              # $48 = '0' converts to ASCII
    pushq %rdx                  # push 5
    cmpq $0, %rax               # check if rax = 0, aka 1 digit
    je _putIntinBuffer          # if zero we can put it in the buffer
    jmp _putIntConvert
_putIntinBuffer:
    popq %rdi                   # will be useful in neg case
    cmpq $0, %rdi               # compare with 0
    je _putIntreturn
    call putChar          
    jmp _putIntinBuffer
_putIntnegative:                # puts in a negative ascii into rdi and pushes it into buffer via putchar
    pushq %rdi
    movq $45,%rdi               # 45 = '-' converts to ASCII 
    call putChar
    popq %rdi
    negq %rdi
    jmp _putIntRDItoRAX
_putIntOneDigit:
    movq %rax, %rdx             # move RAX to RDX
    movq $0, %rax               # set RAX to 0 to implicate one digit
    jmp _putIntCheckZero
_putIntreturn:
    ret

putText:
    mov %rdi, %rcx               # Moving the message from %rdi to %rcx
    mov $0, %rdi                 # Setting %rdi back to 0

_moveCharacterLoop:              # loop that checks if the text contains any NULL-terminators and put value in %dil to be send of to putChar function
    movb (%rcx), %dil            # takes out each individual byte and assigns it to %dil
    cmp $0, %dil                 # compares if the byte is a NULL-terminator
    je _retMoveCharacterLoop     # if it doesnt contain null-terminator it will continue with the loop
    call putChar                 # calls putChar
    add $1, %rcx                 # increments %rcx so we can take out the next byte from the text
    jmp _moveCharacterLoop       # Jumps back to beginning of loop
    
_retMoveCharacterLoop:
    ret

putChar:
    movq output_offset, %rax     # moves the value from output_offset to %rax
    cmpq $64, %rax
    jge overflow_putChar
    leaq output_buffer, %rdx     # loads the address from output_buffer to %rdx
    movq %rdi, (%rdx, %rax)

    incq %rax                    # increment the pointer since we put a char in the buffer
    movq %rax, output_offset
    jmp _putCharreturn

overflow_putChar:
    movq $0, output_offset       # reset the pointer since we're emptying
    call outImage
_putCharreturn:
    ret

getOutPos:
    movq output_offset, %rax
    ret

setOutPos:
    cmpq $0, %rdi                # Checks if value is less than 0
    jle _lessThan
    cmpq $63,%rdi			     # Checks if value is greater than 64
    jge _moreThan
    movq %rdi, output_offset
    ret
_lessThan:
    movq $0,%rdi
    movq %rdi, output_offset
    ret
_moreThan:
    movq $63,%rdi
    movq %rdi, output_offset
    ret
