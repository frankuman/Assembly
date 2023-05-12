
.intel_syntax noprefix

.data

    message: .asciz "Hello World!"

.text

.global main

main:
    xor eax, eax
    lea rdi, [rip + message]
    jmp puts