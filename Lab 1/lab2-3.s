@ int factorial(int number){
@ if (number > 1){
@     return(number * factorial(number - 1));
@ }
@ else{
@     return(1);
@ }
numbers: //Our list, end with 0
    .word   1,2,3,4,5,6,7,8,9,10,0

.global _start

factorial: // -> IN: r0 UT: r0
    PUSH {r1,r2,lr}
    CMP r0,#1
    BEQ return
    MOV r1,r0 //r1 = r0
    SUB r0,r0,#1 // r1 - 1
    BL factorial //recursion
    MUL r2,r1,r0 // number = factorial(number - 1)*number
    MOV r0,r2 //mov answer to r0
    POP {r1,r2,pc} 

return:
    MOV r0,#1 //we go here when r0 = 1
    POP {r1,r2,pc}

_start:
    LDR r4, =numbers
    loop:
        LDR r0, [r4],#4
        CMP r0, #0
        BEQ finish
        
        BL factorial
        MOV r6,r0 //Show answer at r6 for simplicity

    
        b loop

    finish:
        B _end
_end:
    B _end
.end