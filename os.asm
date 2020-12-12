#include "650xlogic.asm"

#include "decls.asm"

start:		.org U2
    ldX stackBottom
    txS

; lets start a riot
    ldA #11111111b
    stA solDir
    ldA #00010000b
    stA solData

    ldA #11111111b
    stA lampDir
    ldA #11110000b
    stA lampData


    ldA #11101001b
    ;stA lampData
    ;ldA #00000001b
    ;stA lampData

    ldA #0
    stA lampTimer

; lets start another riot

; todo

    clI

    ldA #255
    stA U6+$1F

loop:
    nop
    jmp loop

irq:
    inc lampTimer

    ldA #00000001b
    bit lampTimer
    ifeq
        ldA #00101001b
    else
        ldA #00100110b
    endif
    stA lampData

    ldA #00000000b
    stA lampData

    
    ldA #255
    stA U6+$1F
    rti

uhhh:
    nop
    jmp uhhh
interrupt2:
    nop
    jmp interrupt2

pointers: 	.org U3end-7
	.lsfirst		
	.dw uhhh			
	.dw interrupt2 ; NMI?			
	.dw start
    .dw irq
	
	
	.end