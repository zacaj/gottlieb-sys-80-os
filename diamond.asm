#define cBottomDrop #1
#define cLeftDrop #2
#define fLeftRamp #3
#define fTopDome #4
#define cTopDrop #5
#define cRightDrop #6
#define fBottomDome #7
#define cKnocker #8
#define cOuthole #9
#define lBottomTrip lampSol(18,5,0100b)
#define lBallRelease lampSol(2,1,0100b)
#define lLock lampSol(13,4,0010b)
#define lKickback lampSol(14,4,0100b)
#define lLeftTrip lampSol(15,4,1000b)
#define lTopTrip lampSol(16,5,0001b)
#define lRightTrip lampSol(17,5,0010b)
#define lEnableFlippers lampSol(0,1,0001b)
#define lTilt lampSol(1,1,0010b)

#include "os.asm"

tempa:          .equ gameRAM+$00 ; 10mil
temph:          .equ gameRAM+$07 ; 1s

.org U3 + (64*2)

game_init:
game_loop:
game_afterQueue:
game_timerTick:
    rts

swGameOver:
    cmp #$47 ; startButton button  ih
    ifeq
        ldA #1<<6 ; trough switch
        bit strobe0+4
        ifne
            jsr startGame
        endif
        done()
    endif
    cmp #$66 ; outhole  uj
    ifeq
        jmp outhole
    endif
    cmp #$74 ; lock
    ifeq
        ldA lLock
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

    jsr startBall

    rts

startBall:
    ldA lBallRelease
    jsr fireSolenoid

    ldA lEnableFlippers
    jsr turnOnSolenoid

    rts

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
        done()
    endif

    ldA #$20 ; ' '
    cmp p3h
    ifeq
        ldA #$30 ; '0'
        stA p3h-0
        stA p3h-1
        done()
    endif

    ldA #$20 ; ' '
    cmp p4h
    ifeq
        ldA #$30 ; '0'
        stA p4h-0
        stA p4h-1
        done()
    endif

    done()

nothing:
    nop
    jmp afterQueueRun

outhole:
    ldA cOuthole
    jsr fireSolenoid
    jmp afterQueueRun

right1:
    nop
    jmp afterQueueRun

queen: 
    jmp afterQueueRun

ace: ; yd
    jmp afterQueueRun
joker: ; yf
    ldA lEnableFlippers
    jsr turnOnSolenoid
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

tenPoints: ; rf
    score10x(3)
    done()
    


textStart:
testText: .text " TEST TEXT \000"
t_switch: .text " SWITCH XX \000"

.org U3
switchCallbacks:
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw right1  \.dw nothing \.dw ten \.dw ace \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw tenPoints \.dw jack   \.dw joker \.dw queen \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw ramp \.dw leftLane \.dw nothing \.dw startButton 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw leftSpinner \.dw rightLane \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw rightSpinner \.dw skillshot \.dw outhole \.dw nothing 
    .dw leftSideLane \.dw nothing \.dw nothing \.dw nothing \.dw lock \.dw nothing \.dw nothing \.dw nothing 