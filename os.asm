#include "650xlogic.asm"

#include "decls.asm"

#include "game.asm"

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
    adc #$10
    stA lamp1+9

; lets start another riot
    ldA #01111111b
    stA digitDir
    ldA #00000000b
    stA digitData

    ldA #11111111b
    stA segmentDir
    ldA #00000000b
    stA segmentData

    ;ldA #$07
    ;stA p1a+1
    ;stA p3a+2
    ldX #digit1
    ldA #$30
seed:
    stA 0, X
    adc #1
    inX
    cpX #digit40
    bne seed

; a RIOT
    ldA #00000000b
    stA U4a_dir

    ldA #11111111b
    stA U4b_dir
    ldA #00000001b
    stA strobes

; todo

    ldX #queueLow
    stX curQueueStart
    stX curQueueEnd

    clI

    ldA #255
    stA U6_timer

    ldA #255
    stA U5_timer

    ldA #255
    stA U4_timer

loop:
    ldX curQueueStart
    cpX curQueueEnd
    ifne
        ldA queueHigh-queueLow, X
        ifne ; active address
            ldA queueLeft-queueLow, X
            ifeq ; timer expired
                ldA queueHigh-queueLow, X 
                stA queueTemp+0
                ldA 0, X
                stA queueTemp+1
                ldA #0
                stA queueHigh-queueLow, X
                jmp (queueTemp)
            endif
        endif
afterQueueRun:
        ldX curQueueStart
        inX 
        cpX #queueLowEnd
        ifeq
            ldX #queueLow
        endif
        stX curQueueStart
    endif

    jmp loop

irq: 
    phA
    tXA
    phA
    tYA
    phA

    ; update matrix
    ldA #10000000b
    bit U4_irq
    ifne
        ldA #10
        stA U4_timer

        ldX curSwitch

        ldA returns
        eor sswitch1, X ; 1 = switch not settled
        eor #11111111b ; 1 = switch is settled
        stA switchTemp 

        ldA returns
        eor switch1, X ; 1 = switch != new
        and switchTemp ; 1 = switch != new AND is settled
        stA switchTemp

        ifne ; at least one switch in column changed
            ldA curSwitch+0
            asl A
            asl A
            asl A
            asl A
            tAY
            ldA #00000001b
l_switch:
            bit switchTemp
            ifne ; switch changed
                phA
                and switch1, X
                ifeq ; was off, now on
                    stY switchY
                    ldA switchCallbacks+0, Y
                    ldY curQueueEnd
                    stA queueHigh-queueLow, Y
                    ldY switchY
                    ldA switchCallbacks+1, Y
                    ldY curQueueEnd
                    stA 0, Y
                    ldA #0
                    stA queueLeft-queueLow, Y
                    inY
                    cpY #queueLowEnd
                    ifeq
                        ldY #queueLow
                    endif
                    stY curQueueEnd
                    ldY switchY
                endif

                plA
                phA
                eor switch1, X
                stA switch1, X

                plA
            endif
            inY
            inY
            asl A
            bne l_switch
        endif

        ldA returns
        stA sswitch1, X


        ldA strobes
        asl A
        ifeq
            ldA #00000001b
        endif
        stA strobes
        inX
        cpX #8
        ifeq
            ldX #0
        endif
        stX curSwitch  
    endif 

    ; update displays
    ldA #10000000b
    bit U5_irq
    ifne
        ldA #64
        stA U5_timer

        ; load lower nibble
        ldX curDigit
        ifeq
            ldA #00000001b
        else
            ldA digit1-2, X
            and #00001111b
        endif
        stA U5b

        ; latch it
        ;ldA U5a
        ;orA #00010000b
        ;stA U5a
        ;and #11101111b
        ;stA U5a     
        ldA #00000000b
        stA U5a

        ; load high nibble
        ldX curDigit
        ifeq
            ldA #00000000b
        else
            ldA digit1-2, X
            and #11110000b
            lsr A
            lsr A
            lsr A
            lsr A
        endif
        stA U5b

        ; latch it
        ldA #00110000b
        stA U5a
       
        ; latch digit to display
        ldA U5b
        orA #00010000b
        stA U5b

        

        ; now repeat for lower display
        ; load lower nibble
        ldX curDigit
        ifeq
            ldA #00000001b
        else
            ldA digit21-2, X
            and #00001111b
        endif
        stA U5b

        ; latch it
        ;ldA U5a
        ;orA #00010000b
        ;stA U5a
        ;and #11101111b
        ;stA U5a     
        ldA #00000000b
        stA U5a

        ; load high nibble
        ldX curDigit
        ifeq
            ldA #00000000b
        else
            ldA digit21-2, X
            and #11110000b
            lsr A
            lsr A
            lsr A
            lsr A
        endif
        stA U5b

        ; latch it
        ldA #00110000b
        stA U5a
       
        ; latch digit to display
        ldA U5b
        orA #00100000b
        stA U5b

        inX
        cpX #22
        ifeq
            ldX #0
        endif
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

    plA
    tAY
    plA
    tAX
    plA
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