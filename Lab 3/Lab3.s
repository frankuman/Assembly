
# .intel_syntax noprefix

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
    movq $0, input_offset
    leaq input_buffer, %rdi # Points to the input_buffer
    movq $64, %rsi          # Sets the maximum characters to 64
    movq  stdin, %rdx        # Gets values from stdin
    call fgets              # calls fgets
    leaq input_offset, %rax
    movq $0, %rax
    ret

getInt:

    push %r10
    push %r11 
    push %r12

_getIntGetNextValue:
    leaq input_buffer, %rax
    movq input_offset, %r10
    leaq (%rax, %r10), %rdi # Current buffer position
    movq $0, %rax # the value
    movq $0, %r11 # the sign
    movzbq (%rdi), %r12
    cmpb $0, (%rdi)
    je _getIntInImage  # jump if equal
    cmpb $'\n', (%rdi)
    je _getIntInImage  # jump if equal
    # jmp _getIntCheckBlank # jump

_getIntCheckBlank:
    cmpb $' ', (%rdi)   # compare binary to see if there is a space
    jne _getIntCheckPlus

    incq %rdi           # increment %rdi by 1
    incq %r10           # increment %r10 by 1

    jmp _getIntCheckBlank
_getIntCheckPlus:
    cmpb $'+', (%rdi)   # compare binary to see if there is a plus
    jne _getIntCheckMinus

    incq %rdi           # increment %rdi by 1
    incq %r10           # increment %r10 by 1

    jmp _getIntConvert
_getIntCheckMinus:
    cmpb $'-', (%rdi)   # compare binary to see if there is a space
    jne _getIntConvert
    movq $1, %r11

    incq %rdi           # increment %rdi by 1
    incq %r10           # increment %r10 by 1
_getIntConvert:
    cmpb $'0', (%rdi)
    jl  _getIntFlag            # If less than 0 we need to do something
    cmpb $'9', (%rdi)
    jg _getIntFlag             # If more than 9 we need to do something

    movzbq (%rdi), %r12
    subq $'0', %r12
    imulq $10, %rax
    addq %r12,%rax
    incq %rdi           # increment %rdi by 1
    incq %r10           # increment %r10 by 1
    # leaq 1(%rdi), %rdi
    incq %r12

    jmp _getIntConvert
_getIntFlag:
    cmpq $1, %r11         # Compare the value of %R11 with 1
    jne _getIntEnd        # Jump to lEnd if %r11 is not equal to 1
    negq %rax             # Negate the value in the %rax register
_getIntEnd:
    movq %r10, input_offset
    pop %r10 
    pop %r11 
    pop %r12
    ret

_getIntInImage:
    pushq %rax
    call inImage
    popq %rax
    jmp _getIntGetNextValue

getText: # RSI: Antal tecken, RDI: Buffert
    push %rbx
    movq $0, %rbx
    movq input_offset, %rcx
    leaq input_buffer, %rax
    movq (%rax, %rcx), %rdx
    cmpq $0, %rdx
    jne getTextLoop
    call inImage
getTextLoop:
    cmpq $0, %rsi
    je returnGetText
    movq (%rax, %rcx), %rdx
    incq %rcx
    movq %rdx, (%rdi)
    incq %rbx
    cmpb $0, (%rdi)
    je returnGetText
    decq %rsi
    incq %rdi
    jmp getTextLoop
returnGetText:
    movq %rcx, input_offset
    movq %rbx, %rax
    pop %rbx
    ret

getCharje:
    call inImage
getChar:
    push %rbx
    movq input_offset, %rbx
    leaq input_buffer, %rdx
    cmpb $0, (%rdx, %rbx)
    je getCharje
    movq (%rdx, %rbx), %rax
    incq %rbx
    movq %rbx, input_offset
    pop %rbx
    ret

getInPos:
    movq input_offset, %rax
    ret

setInPos:
    cmpq  $0, %rdi
    jle Inposle
    cmpq $63, %rdi
    jge Inposge
    movq %rdi, input_offset
    ret
Inposle:
    movq $0, input_offset
    ret
Inposge:
    movq $63, input_offset
    ret

# <-------------------- utmatningar -------------------->
outImage:
    call putChar
    movq $0,output_offset
    leaq output_buffer, %rdi
    xor %rax, %rax
    jmp puts
    

# putInt:
# 	movq    %rdi, %rdx
# 	movq    $output_buffer, %rsi
# 	movq    $0, %r8
# 	movq    $10, %r11
# 	xorq    %rax, %rax
# 	movq    %rdx, %rax
# checkNegInt:
# 	cmpq	$0, %rdx
# 	jge	putIntLoop
# 	pushq	%rax
# 	call	getOutPos
# 	movb	$'-', (%rsi, %rax)
# 	incq	%rax
# 	movq	%rax, output_offset
# 	popq	%rax
# 	negq	%rax
# putIntLoop:
# 	xorq    %rdx, %rdx
# 	idivq   %r11
# 	addq    $48, %rdx
# 	pushq   %rdx
# 	subq    $48, %rdx
# 	incq    %r8
# 	cmpq    $0, %rax
# 	jg      putIntLoop
# 	call    getOutPos
# outIntLoop:
# 	cmpq	$64, %rax
# 	jne     addToOutbuf
# 	pushq	%rdi
# 	pushq	%rax
# 	call    outImage
# 	popq 	%rax
# 	popq 	%rdi
# addToOutbuf:
# 	popq    %rdx
# 	movb    %dl, %r10b
# 	movb 	%r10b, (%rsi, %rax)
# 	decq    %r8
# 	incq    %rax
# 	cmpq    $0,%r8
# 	je      putIntEnd
# 	jmp     outIntLoop
# putIntEnd:
# 	movq 	%rax, output_offset
# 	ret


putInt:
    pushq $0
    movq $10, %r12       # Set the divisor to 10
    movq %rdi, %rax

_putIntConvert:
    cqto                 
    idivq %r12           # %rsi % 10 (RAX = 0, RDX = 5)
    addq $'0', %rdx      # converts to ASCII
    pushq %rdx           # push 5

    cmpq $0, %rax        # check if rax = 0, aka 1 digit
    je _putIntinBuffer   # putinbuffer
    jmp _putIntConvert
_putIntinBuffer:
    popq %rdi            # will be useful in neg case
    cmpq $0, %rdi        # compare with 0
    je _putIntreturn
    call putChar          
    jmp _putIntinBuffer
_putIntreturn:
    ret


putText:
    mov %rdi, %rcx     # Moving the message from %rdi to %rcx
    mov $0, %rdi       # Setting %rdi back to 0

    move_character_Loop:                # loop that checks if the text contains any NULL-terminators and put value in %dil to be send of to putChar function
        movb (%rcx), %dil               # takes out each individual byte and assigns it to %dil
        cmp $0, %dil                    # compares if the byte is a NULL-terminator
        je return_move_character_loop   # if it doesnt contain null-terminator it will continue with the loop
        call putChar                    # calls putChar
        add $1, %rcx                    # increments %rcx so we can take out the next byte from the text
        jmp move_character_Loop         # Jumps back to beginning of loop
    
    return_move_character_loop:
        ret

putChar:
    movq output_offset, %rax    # moves the value from output_offset to %rax

    cmpq $64, output_offset
    jge overflow_putChar

    leaq output_buffer, %rdx    # loads the address from output_buffer to %rbx

    movq %rdi, (%rdx, %rax)


    incq %rax
    movq %rax, output_offset
    jmp _putCharreturn

overflow_putChar:
    call outImage
_putCharreturn:
    ret

getOutPos:
    movq $output_offset, %rax
    ret
setOutPos:
    cmpq $0, %rdi               # kollar ifall mindre än 0
    jle _lessThan
    cmpq $63,%rdi			# kollar ifall större än 64
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
