@ int factorial(int number){
@ if (number > 1){
@     return(number * factorial(number - 1));
@ }
@ else{
@     return(1);
@ }
numbers:
    .word	1,2,3,4,5,6,7,8,9,10,0

.global _start
.text
factorial:
    PUSH{ lr }
    CMP r5,#1
    MOVLE r5,#1
    BLE factFinish:
    SUB SP,SP,#4
    MOV r6,r5
    SUB r6,r6,#1
    BL factorial
    MUL r5,r6,r5
    ADD SP,SP,#4
    B factFinish



factFinish:
    POP{ pc }
_start:
    LDR r4, =numbers //load into r4
    loop:
        
        LDR r5, [r4], #4 //we take out first int and move pointer
        CMP r5, #0 // if 0 we finito
        BEQ finish //move to finished if 0
        BL factorial
        b loop

    finish:
        B _end
_end:
    B _end

.end