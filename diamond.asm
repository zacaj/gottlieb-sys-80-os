#define cBottomDrop #1
#define cLeftDrop #2
#define fLeftRamp #3
#define fTopDome #4
#define cTopDrop #5
#define cRightDrop #6
#define fBottomDome #7
#define cKnocker #8
#define cOuthole #9
#define cBottomTrip lampSol(18,5,0100b)
#define cBallRelease lampSol(2,1,0100b)
#define cLock lampSol(13,4,0010b)
#define cKickback lampSol(14,4,0100b)
#define cLeftTrip lampSol(15,4,1000b)
#define cTopTrip lampSol(16,5,0001b)
#define cRightTrip lampSol(17,5,0010b)
#define cEnableFlippers lampSol(0,1,0001b)
#define cTilt lampSol(1,1,0010b)

#define lFlush100 32
#define l1x 36
#define lLeftLane 47
#define lSkillTop 42

#include "os.asm"

tempa:          .equ gameRAM+$00 ; 10mil
temph:          .equ gameRAM+$07 ; 1s
gFlags:         .equ gameRAM+$08 ; UUUUUUU trough settling

.org U3 + (64*2)

game_init:
    jsr startAttract
game_loop:
game_afterQueue:
game_timerTick:
    rts

startAttract:
    ldA #10000000b
    ;stA lamp1+0
    ldA #10000000b
    stA lamp1+4

    ldA #11110101b
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

    rts

swGameOver:
    cmp #$47 ; startButton button  ih
    ifeq
        ldA #1<<6 ; trough switch
        bit strobe0+4
        ifne
            jmp startGame
        endif
        done()
    endif
    cmp #$66 ; outhole  uj
    ifeq
        jmp outhole
    endif
    cmp #$74 ; lock
    ifeq
        wait(300)
        ldA cLock
        jsr fireSolenoid
        done()
    endif
    done()

startGame:
    ldA #$20 ; ' '
    ldX #p1a
    ldY #p4h-p1a+1
    jsr set
    ldX #tempa
    ldY #temph-tempa+1
    jsr set

    ldA #$30 ; '0'
    stA p1h-0
    stA p1h-1

    ldA #0
    stA curPlayer
    ldA #$31 ; '1'
    stA curBall

    jsr syncDigits

    jmp startBall

startBall: ; no exit
    jsr syncDigits
    
    ldA #0
    ldX #lamp1
    ldY #lamp12-lamp1+1
    jsr set

    flashLamp(lSkillTop)

    lampOn(lFlush100)

    ldA cEnableFlippers
    jsr turnOnSolenoid

    lampOn(l1x)

    lampOn(lLeftLane)

    ldY #255
    ldA cBallRelease
    jsr fireSolenoidFor

    done()

startButton:
    ldA #$31 ; '1'
    cmp curBall
    ifne
        done()
    endif

    ldA #$20 ; ' '
    cmp p2h
    ifeq
        ldA #$30 ; '0'
        stA p2h-0
        stA p2h-1
        jmp playerAdded
    endif

    ldA #$20 ; ' '
    cmp p3h
    ifeq
        ldA #$30 ; '0'
        stA p3h-0
        stA p3h-1
        jmp playerAdded
    endif

    ldA #$20 ; ' '
    cmp p4h
    ifeq
        ldA #$30 ; '0'
        stA p4h-0
        stA p4h-1
        jmp playerAdded
    endif
playerAdded:
    jsr syncDigits
    done()

nothing:
    nop
    jmp afterQueueRun

outhole:
    wait(200)
    ldA cOuthole
    jsr fireSolenoid
    done()

trough: ; ug
    wait(300)

    ldA #1b
    bit gFlags
    ifne
        done()
    endif

    ldA gFlags
    orA #1b
    stA gFlags

    ldA #1<<6
    bit strobe0+4
    ifne
        ; end ball
        ldY #t_bonus-textStart
        jsr setAtoOtherDisplay
        tAX
        jsr writeText
        wait(700)

        score1Kx(1)

        ; ball done, advance game
        
        ldA curPlayer
        cmp #3
        beq nextBall ; if on player 3, go to next ball

        ; if not on player 3, check if next player is active
        inc curPlayer
        jsr setXToCurPlayer10
        inX
        ldA 0, X
        cmp #$20 ; ' '
        ifeq
            ; next player not active (current player is last player)
nextBall:
            ; go to next ball
            inc curBall

            ldA #0 ; go back to first player
            stA curPlayer

            ; check if this was the last ball
            ldA curBall
            cmp #$34 ; '4'
            ifAge ; game over
                ldA cEnableFlippers
                jsr turnOffSolenoid

                jsr syncDigits
                jsr startAttract

                jmp e_trough
            endif
        endif
        
        ; player+ball updated, start next ball

        ldA gFlags
        and #11111110b
        stA gFlags

        jmp startBall
    endif

e_trough:
    ldA gFlags
    and #11111110b
    stA gFlags

    done()



right1:
    nop
    jmp afterQueueRun

queen: 
    jmp afterQueueRun

ace: ; yd
    score10x(1)
    wait(500)
    score10x(2)
    done()
joker: ; yf
    ldA cEnableFlippers
    jsr turnOnSolenoid
    ldA cOuthole
    jsr fireSolenoid
    jmp afterQueueRun
leftLane: ; yg
    jmp afterQueueRun
rightLane: ; yh
    jmp afterQueueRun
skillshot: ; yj
    jmp afterQueueRun
ten: ; td
    jmp afterQueueRun
jack: ; tf
    jmp afterQueueRun
ramp: ; tg
    jmp afterQueueRun
leftSpinner: ; th
    jmp afterQueueRun
rightSpinner: ; tj
    jmp afterQueueRun
lock: ; tk
    jmp afterQueueRun

leftSideLane: ; ak
    ldA #7
    ldX #digit21+5
    ldY #5
    jsr addScore
    jsr refreshDisplays
    jmp afterQueueRun

sling: ; rf
    score10x(1)
    done()
    


textStart:
testText: .text " TEST TEXT \000"
t_switch: .text " SWITCH XX \000"
t_bonus:  .text "BONUS: \000"

.org U3
switchCallbacks:
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw right1  \.dw nothing \.dw ten \.dw ace \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw sling \.dw jack   \.dw joker \.dw queen \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw ramp \.dw leftLane \.dw trough \.dw startButton 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw leftSpinner \.dw rightLane \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw rightSpinner \.dw skillshot \.dw outhole \.dw nothing 
    .dw leftSideLane \.dw nothing \.dw nothing \.dw nothing \.dw lock \.dw nothing \.dw nothing \.dw nothing 