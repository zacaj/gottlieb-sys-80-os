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
    stA lampData
    ;ldA #00000001b
    ;stA lampData

    ldA #0
    stA lampTimer

; lets start another riot
    ldA #01111111b
    stA digitDir
    ldA #00000000b
    stA digitData

    ldA #11111111b
    stA segmentDir
    ldA #00000000b
    stA segmentData

    ldA #$07
    stA p1a+1

; todo

    clI

    ;ldA #255
    ;stA U6_timer

    ldA #255
    stA U5_timer

loop:
    nop
    jmp loop

irq:
    ldX curDigit

    ldA U5a
    and #10001111b
    stA U5a

    ldA p1a, X
    ;and #10001111b
    orA #01110000b
    stA U5b

    inX
    cpX #6
    ifeq
        ldX #0
    endif

    ldA curDigit+0
    orA #00010000b
    stA U5a

    stX curDigit
    
    ldA #64
    stA U5_timer

    ;inc lampTimer
;
    ;ldA #00000001b
    ;bit lampTimer
    ;ifeq
    ;    ldA #00101001b
    ;else
    ;    ldA #00100110b
    ;endif
    ;stA lampData
;
    ;ldA #00000000b
    ;stA lampData
;
    ;
    ;ldA #255
    ;stA U6_timer
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