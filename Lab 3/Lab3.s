    .data
input_buffer: .space 64  # input buffer
output_buffer: .space 64 # output buffer
maxBuffer: .quad 64 #  maximum size of a 64 bit buffer
current_pos: .quad 0 # current position
    
    .text
    #  functions for input
    .global	main
    .global inImage
    .global getInt
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
main:

# inmatningar
inImage:
    mov %rax,0 # read
    mov %rdi,0 # input /stdin
    mov %rsi, input_buffer # pointer to buffer
    mov %rdx, input_size # max number to read (64?)
    syscall
    mov DWORD current_pos, 0
    ret
getInt:
    ret
getChar:
    ret
getInPos:
    ret
setInPos:
    ret

# utmatningar
outImage:
    ret
putInt:
    ret
putText:
    ret
putChar:
    ret
getOutPos:
    ret
setOutPos:
    ret
