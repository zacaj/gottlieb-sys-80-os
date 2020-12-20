#include "650xlogic.asm"

#include "decls.asm"

.org U2
#include "disp80B.asm"
#include "util.asm"

start:	
    clD  	
    ldX RAM
    ldA #0
l_clear:
    stA 0, X
    inX
    cpX stackBottom+1
    bne l_clear

    ldX #stackBottom-$100
    tXS

; lets start a riot
    ldA #11100000b
    stA solData
    ldA #11111111b
    stA solDir

    ldA #00001111b
    stA lampData
    ldA #11111111b
    stA lampDir

    ; test
    ldA #00001111b
    stA lampData
    ldA #10101111b
    stA lampData
    ldA #00001111b
    stA lampData



    ;ldA #11101001b
    ;stA lampData
    ;ldA #00000001b
    ;stA lampData

    ldA #10000000b
    ;stA lamp1+0
    ldA #10000000b
    stA lamp1+4

    ldA #10100000b
    ;stA lamp1+1
    ;adc #$10
    ;stA lamp1+2
    ;adc #$10
    ;stA lamp1+3
    ;adc #$10
    ;stA lamp1+4
    ;adc #$10
    stA lamp1+5
    ;adc #$10
    stA lamp1+6
    ;adc #$10
    stA lamp1+7
    ;adc #$10
    stA lamp1+8
    ;adc #$10
    stA lamp1+9
    stA lamp1+10
    stA lamp1+11
    stA lamp1+12

; lets start another riot
    ldA #01111111b
    stA digitDir
    ldA #00000000b
    stA U5a

    ldA #11111111b
    stA segmentDir
    ldA #00000000b
    stA U5b



; seed some display data
    ;ldA #$07
    ;stA p1a+1
    ;stA p3a+2

    jsr initSys80B  

    ldX #digit1
    ldA #$30
seed:
    stA 0, X
    adc #1
    inX
    cpX #digit40
    bne seed

    ldA #$01
    stA digit1-2
    stA digit21-2
    ldA #$C0
    stA digit1-1
    stA digit21-1

    jsr refreshDisplays

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


    ldA #$20
    stA digit21+2
    stA digit21+3
    stA digit21+4
    ldA #$30
    stA digit21+5
    stA digit21+6
    jsr refreshDisplays


    ; test
    ldA #00001111b
    stA lampData
    ldA #10111111b
    stA lampData
    ldA #00001111b
    stA lampData


    ;ldX #youreWelcome-textStart
    ;ldY #digit1+0
    ;jsr writeText
    ;ldX #chuckwurt-textStart
    ;ldY #digit21+0
    ;jsr writeText
    ;jsr refreshDisplays

    jsr game_init


    ldA #100
    stA U6_timer

    ;ldA #255
    ;stA U5_timer

    ldA #50
    stA U4_timer

    clI



loop:
    ldX curQueueStart
    cpX curQueueEnd
    ifne
        ldA queueHigh-queueLow, X
        ifne ; active address
            ldA queueLeft-queueLow, X
            ifeq ; timer expired
                ; load queue address
                ldA queueHigh-queueLow, X 
                stA queueTemp+1
                ldA 0, X
                stA queueTemp+0
                ldA #0
                stA queueHigh-queueLow, X
                ldA queueA-queueLow, X
                
                ; step queue
                ldX curQueueStart
                cpX #queueLowEnd
                ifeq
                    ldX #queueLow
                else
                    inX 
                endif
                stX curQueueStart
                jmp (queueTemp)
afterQueueRun:
                ldA #0001b
                bit lamp1+0
                ifne ; in game
                    jsr syncDigits
                    jsr game_afterQueue
                    jsr refreshDisplays
                endif
            endif
        endif
    endif

    jsr game_loop

    jmp loop

irq: 
    phA
    tXA
    phA
    tYA
    phA

#if 1
    ; update solenoids
    ldA #10000000b
    bit U5_irq
    ifne
        ; disable timer
        ldA U5+$04

        jsr turnOffCurSolenoid
    endif
#endif

    ; update matrix
    ldA #10000000b
    bit U4_irq
    ifeq
        jmp afterSwitch
    endif
        ldA #2
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

        ifeq
            jmp afterSwitchChanged
        endif ; at least one switch in column changed
            ldA curSwitch
            asl A
            asl A
            asl A
            asl A
            tAY
            ldA #00000001b ; bit in the strobe to check
l_switch:
            bit switchTemp
            ifne ; switch changed
                phA
                and switch1, X
                ifeq ; was off, now on
                    stY switchY

                    ; check if in game over or not
                    ldA #00000001b
                    bit lamp1

                    ifeq 
                        ; in game over
                        ldY curQueueEnd
                        ldA #swGameOver&$FF
                        stA 0, Y
                        ldA #swGameOver>>8
                        stA queueHigh-queueLow, Y
                    else ; not in game over
                        ; store address in queue
                        ldA switchCallbacks+1, Y
                        ldY curQueueEnd
                        stA queueHigh-queueLow, Y
                        ldY switchY
                        ldA switchCallbacks+0, Y
                        ldY curQueueEnd
                        stA 0, Y
                    endif

                    ; compute switch number
                    ldA switchY
                    lsr A
                    and #00000111b
                    stA queueA-queueLow, Y
                    ldA switchY
                    and #11110000b
                    orA queueA-queueLow, Y
                    stA queueA-queueLow, Y

                    ; enable entry
                    ldA #0
                    stA queueLeft-queueLow, Y

                    ; increment queue
                    cpY #queueLowEnd
                    ifeq
                        ldY #queueLow
                    else
                        inY
                    endif
                    stY curQueueEnd

#if 1
                    ; show switch on screen
                    tXA
                    phA
                    ldX #t_switch-textStart
                    ldY #digit21+3
                    jsr writeText
                    ldA switchY
                    and #00001111b
                    lsr A
                    adc #$30
                    stA digit21+3+9
                    ldA curSwitch
                    adc #$30
                    stA digit21+3+8
                    jsr refreshDisplays
                    plA
                    tAX
#endif

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
afterSwitchChanged:

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
afterSwitch: 

    ; update lamps
    ldA #10000000b
    bit U6_irq
    ifne
        ldA #255/20
        stA U6_timer

        ldX curLamp

        ldA curLamp
        asl A
        asl A
        asl A
        asl A
        stA lampTemp
        ldA lamp1-1, X
        and #00001111b
        stA lampData
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
    rti
interrupt2:
    nop
    rti

pointers: 	.org U3end-7
	.lsfirst		
	.dw uhhh			
	.dw interrupt2 ; NMI?			
	.dw start
    .dw irq
	
	
	.end