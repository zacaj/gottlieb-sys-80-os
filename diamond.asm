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


.org U3 + (64*2)

game_init:
game_loop:
    rts

nothing:
    nop
    jmp afterQueueRun

right1:
    nop
    jmp afterQueueRun

queen: 
    nop
    ldA lamp1
    eor #00001111b
    stA lamp1
    jmp afterQueueRun

ace: ; yd
    ldA lEnableFlippers
    jsr turnOnSolenoid
    jmp afterQueueRun
joker: ; yf
    ldA lEnableFlippers
    jsr fireSolenoid
    jmp afterQueueRun
leftLane: ; yg
    ldA fLeftRamp
    jsr fireSolenoid
    jmp afterQueueRun
rightLane: ; yh
    ldA fTopDome
    jsr fireSolenoid
    jmp afterQueueRun
skillshot: ; yj
    ldA lBallRelease
    jsr fireSolenoid
    jmp afterQueueRun
ten: ; td
    ldA cTopDrop
    jsr fireSolenoid
    jmp afterQueueRun
jack: ; tf
    ldA cRightDrop
    jsr fireSolenoid
    jmp afterQueueRun
ramp: ; tg
    ldA fBottomDome
    jsr fireSolenoid
    jmp afterQueueRun
leftSpinner: ; th
    ldA cKnocker
    jsr fireSolenoid
    jmp afterQueueRun
rightSpinner: ; tj
    ldA cOuthole
    jsr fireSolenoid
    jmp afterQueueRun
lock: ; tk
    ldA lBottomTrip
    jsr fireSolenoid
    jmp afterQueueRun

leftSideLane: ; ak
    ldA #7
    ldX #digit21+5
    ldY #5
    jsr addScore
    jsr refreshDisplays
    jmp afterQueueRun
    


textStart:
testText: .text " TEST TEXT \000"
t_switch: .text " SWITCH XX \000"

.org U3
switchCallbacks:
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw right1  \.dw nothing \.dw ten \.dw ace \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw jack   \.dw joker \.dw queen \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw ramp \.dw leftLane \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw leftSpinner \.dw rightLane \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw rightSpinner \.dw skillshot \.dw nothing \.dw nothing 
    .dw leftSideLane \.dw nothing \.dw nothing \.dw nothing \.dw lock \.dw nothing \.dw nothing \.dw nothing 