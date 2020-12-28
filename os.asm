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
    stX curQueue
    stX nextQueue

    ldX #1
    stX curLamp

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
    ldA #00000001b
    bit flags
    ifne ; timer tick
        jsr game_timerTick
    
        ; decrement queue timers
        ldX #queueLow
l_tickQueue:
        ldA queueLeft-queueLow, X
        ifne
            dec queueLeft-queueLow, X
        endif
        inX
        cpX #queueLowEnd+1
        bne l_tickQueue

        ; check in game timers
        ldA #00000001b
        bit lamp1+0
        ifne ; in game
            jsr handleBlinkScore
        endif

        ldA flags
        and #11111110b
        stA flags
    endif

    ; check queue
    ldX nextQueue
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
            
            jmp (queueTemp)
afterQueueRun:
            ldA #0001b
            bit lamp1+0
            ifne ; in game
                jsr syncCurPlayer
                jsr game_afterQueue
                ldA #2000/TIMER_TICK
                stA scoreBlinkTimer
            endif
            jsr refreshDisplays
        endif
    endif

    ; increment queue
    ldX nextQueue
    cpX #queueLowEnd
    ifeq
        ldX #queueLow
    else
        inX
    endif
    stX nextQueue

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
        ldA #0+SWITCH_SPEED
        stA U4_timer

        ldY curSwitch

        ldA returns
        eor sswitch1, Y ; 1 = switch not settled
        eor #11111111b ; 1 = switch is settled
        stA switchTemp 

        ldA returns
        eor strobe0, Y ; 1 = switch != new
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
            tAX
            ldA #00000001b ; bit in the strobe to check
l_switch:
            bit switchTemp
            ifne ; switch changed
                phA
                and strobe0, Y
                ifeq ; was off, now on
                    stX switchY
                    jsr setXtoEmptyQueue
                    stX curQueue

                    ; check if in game over or not
                    ldA #00000001b
                    bit lamp1

                    ifeq 
                        ; in game over
                        ldX curQueue
                        ldA #swGameOver&$FF
                        stA 0, X
                        ldA #swGameOver>>8
                        stA queueHigh-queueLow, X
                    else ; not in game over
                        ; store address in queue
                        ldX switchY
                        ldA switchCallbacks+1, X
                        ldX curQueue
                        stA queueHigh-queueLow, X
                        ldX switchY
                        ldA switchCallbacks+0, X
                        ldX curQueue
                        stA 0, X
                    endif

                    ; compute switch number
                    ldA switchY
                    lsr A
                    and #00000111b
                    stA queueA-queueLow, X
                    ldA switchY
                    and #11110000b
                    orA queueA-queueLow, X
                    stA queueA-queueLow, X

                    ldA #0
                    stA queueLeft-queueLow, X

                    ; increment queue
                    cpX #queueLowEnd
                    ifeq
                        ldX #queueLow
                    else
                        inX
                    endif
                    stX curQueue

#if 0
                    ; show switch on screen
                    tYA
                    phA
                    ldY #t_switch-textStart
                    ldX #digit21+3
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
                    tAY
#endif

                    ldX switchY
                endif

                plA
                phA
                eor strobe0, Y
                stA strobe0, Y

                plA
            endif
            inX
            inX
            asl A
            bne l_switch
afterSwitchChanged:

        ldA returns
        stA sswitch1, Y


        ldA strobes
        asl A
        ifeq
            ldA #00000001b
        endif
        stA strobes
        inY
        cpY #8
        ifeq
            ldY #0
        endif
        stY curSwitch  


        ; also trigger timers
        dec timer
        ifeq
            ldA flags
            orA #00000001b
            stA flags

            ldA #0+TIMER_TICK/SWITCH_SPEED
            stA timer
        endif
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