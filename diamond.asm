#define cBottomDrop 1
#define cLeftDrop 2
#define fLeftRamp 3
#define fTopDome 4
#define cTopDrop 5
#define cRightDrop 6
#define fBottomDome 7
#define cKnocker 8
#define cOuthole 9
#define cBottomTrip lampSol(18,5,0100b)
#define cBallRelease lampSol(2,1,0100b)
#define cLock lampSol(13,4,0010b)
#define cKickback lampSol(14,4,0100b)
#define cLeftTrip lampSol(15,4,1000b)
#define cTopTrip lampSol(16,5,0001b)
#define cRightTrip lampSol(17,5,0010b)
#define cEnableFlippers lampSol(0,1,0001b)
#define cTilt lampSol(1,1,0010b)

#define lShootAgain 3
#define lJokerSpecial 5
#define lAce100k 6
#define lTen 7
#define lJack 8
#define lAce 9
#define lKing 10
#define lQueen 11
#define lTopSpecial 19
#define lKickback 20
#define lJackpot 21
#define ljackpoT 27
#define lDiamond100k 28
#define lDiamond200k 29
#define lDiamond400k 30
#define lDiamondSpecial 31
#define lFlush100 32
#define lFlush250 33
#define lFlushEb 34
#define lFlushSpecial 35
#define l1x 36
#define l2x 37
#define l4x 38
#define l8x 39
#define lSkillSpinner 41
#define lSkillTop 42
#define lSkillAll 43
#define lRamp 44
#define lSpinner 45
#define lLock 46
#define lLeftLane 47

#define sCoin $F8
#define sDealTheHand $00
#define sBallStart $F3

#include "os.asm"

tempa:          .equ gameRAM+$00 ; 10mil
temph:          .equ gameRAM+$07 ; 1s
#define TroughSettleBit     1<<0
#define MultiballBit        1<<1
gFlags:         .equ gameRAM+$08
x:              .equ gameRAM+$0A ; 1-15

.org U3 + (64*2)

game_init:
    jsr startAttract
game_loop:
game_afterQueue:
game_timerTick:
    rts

startAttract:
    ldA 10000000b
    ;stA lamp1+0
    ldA 10000000b
    stA lamp1+4

    ldA 11110101b
    ;stA lamp1+1
    ;adc $10
    ;stA lamp1+2
    ;adc $10
    ;stA lamp1+3
    ;adc $10
    ;stA lamp1+4
    ;adc $10
    stA lamp1+5
    ;adc $10
    stA lamp1+6
    ;adc $10
    stA lamp1+7
    ;adc $10
    stA lamp1+8
    ;adc $10
    stA lamp1+9
    stA lamp1+10
    stA lamp1+11
    stA lamp1+12

    rts

swGameOver:
    cmp $47 ; startButton button  ih
    ifeq
        ldA 1<<6 ; trough switch
        bit >strobe0+4
        ifne
            jmp startGame
        endif
        done()
    endif
    cmp $66 ; outhole  uj
    ifeq
        jmp outhole
    endif
    cmp $74 ; lock
    ifeq
        wait(300)
        ldA cLock
        jsr fireSolenoid
        done()
    endif
    ldA sCoin
    jsr playSound
    done()

startGame:
    ldA >sDealTheHand
    jsr playSound
    wait(950)

    ldA $20 ; ' '
    ldX p1a
    ldY p4h-p1a+1
    jsr set
    ldX tempa
    ldY temph-tempa+1
    jsr set

    ldA $30 ; '0'
    stA p1h-0
    stA p1h-1

    ldA 0
    stA curPlayer
    ldA $31 ; '1'
    stA curBall

    jsr syncDigits

    jmp startBall

startBall: ; no exit
    ldA 0
    stA gFlags

    ; turn off all lights
    ldA 0
    ldX lamp1
    ldY lamp12-lamp1+1
    jsr set

    jsr syncDigits

    ldY 80

    ldA cLeftDrop
    jsr fireSolenoidFor
    wait(200)

    ldA cTopDrop
    jsr fireSolenoidFor
    wait(200)

    ldA cRightDrop
    jsr fireSolenoidFor
    wait(200)

    ldA 1
    stA x
    jsr syncX

    flashLamp(lSkillTop)

    wait(1000)

    lampOn(lFlush100)

    ldA cEnableFlippers
    jsr turnOnSolenoid

    lampOn(lLeftLane)

releaseBall:
    ldA sBallStart
    jsr playSound

    ldY 255
    ldA cBallRelease
    jsr fireSolenoidFor

    done()

startButton:
    ldA $31 ; '1'
    cmp >curBall
    ifne
        done()
    endif

    ldA $20 ; ' '
    cmp >p2h
    ifeq
        ldA $30 ; '0'
        stA p2h-0
        stA p2h-1
        jmp playerAdded
    endif

    ldA $20 ; ' '
    cmp >p3h
    ifeq
        ldA $30 ; '0'
        stA p3h-0
        stA p3h-1
        jmp playerAdded
    endif

    ldA $20 ; ' '
    cmp >p4h
    ifeq
        ldA $30 ; '0'
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

    ldA MultiballBit
    bit >gFlags
    ifne ; in multiball
        ldA >gFlags
        and ~MultiballBit
        stA gFlags
        jsr syncX
    endif
    done()

trough: ; ug
    wait(300)

    ldA TroughSettleBit
    bit >gFlags
    ifne
        done()
    endif

    ldA >gFlags
    orA TroughSettleBit
    stA gFlags

    ldA 1<<6
    bit >strobe0+4
    ifne
        ; end ball
        ldY t_bonus-textStart
        jsr setAtoOtherDisplay
        tAX
        jsr writeText
        wait(700)

        score1Kx(1)

        ; ball done, advance game
        
        ldA >curPlayer
        cmp 3
        beq nextBall ; if on player 3, go to next ball

        ; if not on player 3, check if next player is active
        inc curPlayer
        jsr setXToCurPlayer10
        inX
        ldA 0, X
        cmp $20 ; ' '
        ifeq
            ; next player not active (current player is last player)
nextBall:
            ; go to next ball
            inc curBall

            ldA 0 ; go back to first player
            stA curPlayer

            ; check if this was the last ball
            ldA >curBall
            cmp $34 ; '4'
            ifAge ; game over
                ldA cEnableFlippers
                jsr turnOffSolenoid

                jsr syncDigits
                jsr startAttract

                jmp e_trough
            endif
        endif
        
        ; player+ball updated, start next ball

        ldA >gFlags
        and ~TroughSettleBit
        stA gFlags

        jmp startBall
    endif

e_trough:
    ldA >gFlags
    and ~TroughSettleBit
    stA gFlags

    done()

leftLane: ; yg
    score10Kx(1)
    ldA lb(lLeftLane)
    bit >lc(lLeftLane)
    ifne 
        jsr advX
    endif
    done()
rightLane: ; yh
    score10Kx(1)
    ldA lb(lLeftLane)
    bit >lc(lLeftLane)
    ifeq 
        jsr advX
    endif
    done()
advX:
    inc x
    ldA $F0
    bit >x
    ifne ; overflowed
        ldA 15
        stA x
    endif
    jsr syncX
    rts
syncX:
    ldA MultiballBit
    bit >gFlags
    ifne 
        ldA >x
        asl A
        asl A
        asl A
        asl A
    else
        ldA >x
    endif
    stA lc(l1x)
    rts
skillshot: ; yj
    ldA cTopTrip
    jsr fireSolenoid
    jmp checkRoyalFlush
ten: ; td
    score1Kx(5)
    lampOn(lTen)
    jmp checkRoyalFlush
jack: ; tf
    score1Kx(5)
    lampOn(lJack)
    jmp checkRoyalFlush
queen: ; uf
    score1Kx(5)
    lampOn(lQueen)
    jmp checkRoyalFlush
king: ; ud
    score1Kx(5)
    lampOn(lKing)
    jmp checkRoyalFlush
ace: ; yd
    score1Kx(5)
    lampOn(lAce)
    jmp checkRoyalFlush
checkRoyalFlush:
    ldA >lc(lJack)
    cmp 00001111b
    ifeq ; jack - ace on solid
        ldA >lc(lTen)
        and ~lbf(lTen)
        cmp lbf(lTen)
        ifeq ; ten on solid
            flashLamp(lLock)

            ldA 11110000b
            stA lc(lJack)
            flashLamp(lTen)
        endif
    endif
    done()

joker: ; yf
    score1Kx(5)
    done()
ramp: ; tg
    score10Kx(1)
    done()
leftSpinner: ; th
rightSpinner: ; tj
    score1Kx(1)
    done()
lock: ; tk
    score1Kx(1)
    lampOff(lKickback)
    ldA lf(lLock)
    bit >lc(lLock)
    ifne ; capture lit
        lampOff(lLock)
        ldA >gFlags
        orA MultiballBit
        stA gFlags
        jsr syncX
        jmp releaseBall
    else
        wait(300)
        ldA cLock
        jsr fireSolenoid
    endif

    done()

leftSideLane: ; ak
    score1Kx(2)
    lampOn(lKickback)
    done()

sling: ; rf
    score10x(1)
    done()

left1: ; qd
left2: ; qf
left3: ; qg
left4: ; qg
left5: ; qh
    score1Kx(5)
    done()

right1: ; ed
right2: ; ef
right3: ; eg
right4: ; eh
right5: ; ej
    score1Kx(5)
    done()

top1: ; wd
top2: ; wf
top3: ; wg
top4: ; wh
    score1Kx(5)
    done()

pop: ; wj
    score1Kx(1)
    done()

laneChange: ; rj
    done()

bottomDrop: ; rd
    score10Kx(1)
    done()

leftOutlane: ; rg
    ldA lbf(lKickback)
    bit >lc(lKickback)
    ifne
        ldA cKickback
        jsr fireSolenoid
        lampOff(lKickback)
    endif
rightOutlane: ; rk
    score10Kx(1)
    done()
leftInlane: ; rh
rightInlane ; rj
    score1Kx(1)
    done()

textStart:
testText: .text " TEST TEXT \000"
t_switch: .text " SWITCH XX \000"
t_bonus:  .text "BONUS: \000"

.org U3
switchCallbacks:
    .dw nothing \.dw nothing \.dw nothing     \.dw nothing        \.dw nothing      \.dw nothing    \.dw nothing \.dw nothing 
    .dw nothing \.dw nothing \.dw nothing     \.dw nothing        \.dw nothing      \.dw nothing    \.dw nothing \.dw nothing 
    .dw left1 \.dw top1 \.dw right1           \.dw bottomDrop     \.dw ten          \.dw ace        \.dw king \.dw nothing 
    .dw left2 \.dw top2 \.dw right2           \.dw sling          \.dw jack         \.dw joker      \.dw queen   \.dw nothing 
    .dw left3 \.dw top3 \.dw right3           \.dw leftOutlane    \.dw ramp         \.dw leftLane   \.dw trough  \.dw startButton 
    .dw left4 \.dw top4 \.dw right4           \.dw leftInlane     \.dw leftSpinner  \.dw rightLane  \.dw nothing \.dw nothing 
    .dw left5 \.dw pop  \.dw right5           \.dw rightInlane    \.dw rightSpinner \.dw skillshot  \.dw outhole \.dw nothing 
    .dw leftSideLane \.dw pop \.dw laneChange \.dw rightOutlane   \.dw lock         \.dw nothing    \.dw nothing \.dw nothing 