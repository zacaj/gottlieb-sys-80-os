#define cBottomDrop 1
#define cLeftDrop 2
#define fLeftRamp 3
#define fTopDome 4
#define cTopDrop 5
#define cRightDrop 6
#define fBottomDome 7
#define cKnocker 8
#define cOuthole 9
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

sound:      .equ gameRAM+$00

game_init:
    ldA lEnableFlippers
    ;jsr turnOnSolenoid
game_loop:
game_timerTick:
game_afterQueue:
    rts

swGameOver:
    ldA $12
    jsr playSound
    ;ldA $15
    ;jsr playSound

    inc sound
    ldA >sound
    ldA $1B
    jsr playSound
    ;ldA $1A
    ;jsr playSound
    ;ldA $15
    ;jsr playSound
    done()

nothing:
    nop
    jmp afterQueueRun

right1:
    nop
    jmp afterQueueRun

queen: 
    ldA lTilt
    jsr turnOnSolenoid
    jmp afterQueueRun

ace: ; yd
    ldA $11
    jsr playSound
    ldA $0D
    jsr playSound
    ldA lEnableFlippers
    jsr turnOnSolenoid
    jmp afterQueueRun
joker: ; yf
    ldA lEnableFlippers ; worked
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
    ldA lLock
    jsr fireSolenoid
    jmp afterQueueRun
ten: ; td
    ldA lBallRelease
    jsr fireSolenoid
    jmp afterQueueRun
jack: ; tf
    ldA lKickback
    jsr fireSolenoid
    jmp afterQueueRun
ramp: ; tg
    ldA fBottomDome ; worked
    jsr fireSolenoid
    jmp afterQueueRun
leftSpinner: ; th
    ldA lLeftTrip 
    jsr fireSolenoid
    jmp afterQueueRun
rightSpinner: ; tj
    ldA lTopTrip 
    jsr fireSolenoid
    jmp afterQueueRun
lock: ; tk
    ldA cBottomDrop
    jsr fireSolenoid
    jmp afterQueueRun

leftSideLane: ; ak
    ldA 7
    ldX digit21+5
    ldY 5
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