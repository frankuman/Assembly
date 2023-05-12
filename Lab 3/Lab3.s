
# .intel_syntax noprefix

.data
    input_buffer:   .space 64   
    output_buffer:  .space 64
    input_offset:   .quad 0
    output_offset:  .quad 0
    max_buffer:     .quad 64    # maximum size of a 64 bit buffer
    output_string: .asciz "%s\n"
    
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
    movq $0, input_offset   # Resets the offset back to 0
    leaq input_buffer, %rdi # Points to the input_buffer
    movq max_buffer, %rsi   # Sets the maximum characters to 64
    mov  [stdin], %rdx      # Gets values from stdin
    call fgets              # calls fgets
    ret
    
getInt:
    
    jne _getInt_checkIfBufferEmpty
    call inImage
    jmp _getInt_checkSpace

_getInt_checkIfBufferEmpty:
    movq input_offset, %rdx
    cmp max_buffer, %rdx
    jl _getInt_checkSpace
    call inImage

_getInt_checkSpace:
    cmp $32, %rdi



    ret
getText:
    ret
getChar:
    ret
getInPos:
    ret
setInPos:
    ret

# <-------------------- utmatningar -------------------->
outImage:
    xor %rax, %rax
    leaq output_buffer, %rdi
    jmp puts

putInt:
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
    leaq output_buffer, %rbx    # loads the address from output_buffer to %rbx
    movb %dil, (%rbx, %rax, 1)  # Moves one byte to %dil
    inc %rax                    # increments
    mov %rax, output_offset     

    cmp max_buffer, %rax
    jl return_putChar
    movq $0, %rax
    mov %rax, output_offset
    call outImage
    return_putChar:
        ret

getOutPos:
    ret
setOutPos:
    ret
