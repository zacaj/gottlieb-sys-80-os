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


    ;ldA #11101001b
    ;stA lampData
    ;ldA #00000001b
    ;stA lampData

    ldA #$10
    stA lamp1+0
    adc #$10
    stA lamp1+1
    adc #$10
    stA lamp1+2
    adc #$10
    stA lamp1+3
    adc #$10
    stA lamp1+4
    adc #$10
    stA lamp1+5
    adc #$10
    stA lamp1+6
    adc #$10
    stA lamp1+7
    adc #$10
    stA lamp1+8

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

    ldA #255
    stA U6_timer

    ;ldA #255
    ;stA U5_timer

loop:
    nop
    jmp loop

irq:
    ; update displays
    ldA #10000000b
    bit U5_irq
    ifne
        ldA #64
        stA U5_timer

        ldX curDigit

        ldA U5a
        and #10001111b
        stA U5a

        ldA p1a, X
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
    endif

    ; update lamps
    ldA #10000000b
    bit U6_irq
    ifne
        ldA #255/20
        stA U6_timer

        ldX curLamp

        ldA curLamp+0
        asl A
        asl A
        asl A
        asl A
        stA lampTemp
        ldA lamp1-1, X
        and #00001111b
        orA lampTemp
        stA lampData

        and #00001111b
        stA lampData

        ldA lamp1-1, X
        lsr A
        lsr A
        lsr A
        lsr A
        eor lamp1-1, X
        stA lamp1-1, X

        inX
        cpX #13
        ifeq
            ldX #1
        endif
        stX curLamp     

    endif
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