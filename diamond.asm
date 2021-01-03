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
#define MultiballBit        1<<1 ; in mutliball
#define IgnoreBottomDropBit 1<<2
#define MbInvalidBit        1<<3 ; no switches hit yet during mb
#define SpadesTrippedBit    1<<4 ; set once any spades have been tripped this ball
#define DiamondCollectBit   1<<5 ; set to pause count down while collecting
#define StartSettleBit      1<<6
gFlags:         .equ gameRAM+$08
x:              .equ gameRAM+$0A ; 1-15
leftIgnore:     .equ gameRAM+$0B ; bits 2-6 = left drop 1-5
rightIgnore:    .equ gameRAM+$0C ; bits 2-6 = right drop 1-5
topIgnore:      .equ gameRAM+$0D ; bits 2-5 = top drop 1-4
rampTimer:      .equ gameRAM+$0E
skillshotTimer: .equ gameRAM+$0F
#define SkillshotTime       750
p_flush:        .equ gameRAM+$10 ; +3 bits 0-3: L8-11, bit 4: L7
p_jackpot:      .equ gameRAM+$14 ; +3 bits 1-7: L21-27
#define LockLitBit          1<<0
#define KickbackLitBit      1<<1
#define JokerLitBit         1<<2
p_flags:        .equ gameRAM+$18 ; +3
bonusa:         .equ gameRAM+$20
bonush:         .equ gameRAM+$27
diamonda:       .equ gameRAM+$28
diamondh:       .equ gameRAM+$2F

.org U3 + (64*2)

game_init:
    jsr startAttract
game_loop:
    rts
game_afterQueue:
    ldA >diamondh-4
    cmp $20 ; ' '
    ifne ; diamond bonus is active
    endif

    rts

game_timerTick:
    ldA 0001b
    bit >lamp1+0
    ifeq ; not in game
        rts
    endif

    ldA >rampTimer
    ifne
        dec rampTimer
        ifeq
            lampOff(lRamp)
        endif
    endif

    ldA >skillshotTimer
    ifne
        dec skillshotTimer
        ifeq
            ldA SkillshotTime/TIMER_TICK
            stA skillshotTimer

            ldA lb(lSkillSpinner)
            bit >lc(lSkillAll)
            ifne
                ldA lb(lSkillAll)
            else
                ldA >lc(lSkillAll)
                lsr A
            endif
            stA lc(lSkillAll)
        endif
    endif

    ldA >diamondh-3
    cmp $20 ; ' '
    ifne ; diamond bonus is active
        ldA >gFlags
        and MbInvalidBit
        ifeq
            ldA >gFlags
            and DiamondCollectBit
            ifeq
                ldX diamondh-3
                ldY 5
                ldA 1
                jsr subtractScore

                ldA 1b
                bit >diamondh-5 ; 100k
                ifne
                    ldY t_diamond-textStart
                else
                    ldY t_dBonus-textStart
                endif
            else
                ldY t_diamond-textStart
            endif

            jsr setAtoOtherDisplay
            tAX
            jsr writeText

            ldX diamonda
            ldY 6
            jsr cleanScore

            jsr setAtoOtherDisplay
            clC
            adc 12
            tAX
            ldY diamonda
            ldA 8
            jsr copy 

            jsr refreshDisplays
        endif
    endif
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
    ldA StartSettleBit
    bit >gFlags
    ifne
        done()
    endif
    orA >gFlags
    stA gFlags


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

    ldX 0
l_resetPlayers:
    ldA 0
    stA p_flush, X
    stA p_flags, X
    ldA 00011110b
    stA p_jackpot, X
    inX
    cpX 4
    bne l_resetPlayers

    jsr syncDigits


    ldA >gFlags
    and ~StartSettleBit
    stA gFlags

    jmp startBall

startBall: ; no exit
    ldA 0
    stA gFlags
    stA rampTimer

    ; turn off all lights
    ldA 0
    ldX lamp1
    ldY lamp12-lamp1+1
    jsr set
    ldA $20 ; ' '
    ldX bonusa
    ldY 4
    jsr set
    ldA $30 ; '0'
    ldX bonusa+5
    ldY 3
    jsr set
    ldA $31 ; '1'
    stA bonusa+4
    ldA $20 ; ' '
    ldX diamonda
    ldY diamondh-diamonda+1
    jsr set

    jsr syncDigits

    jsr resetDrops
    jsr tripBottomDrop

    ; set lights

    ldA 1
    stA x
    jsr syncX

    lampOn(lSkillTop)

    ldX >curPlayer

    ldA p_flush, X
    and 00001111b
    stA lc(lJack)
    eor 11111111b
    asl A
    asl A
    asl A
    asl A
    orA >lc(lJack)
    stA lc(lJack)

    ldA 00010000b
    and p_flush, X
    ifne
        lampOn(lTen)
    else
        flashLamp(lTen)
    endif

    jsr syncJackpot

    ldA LockLitBit
    and >p_flags, X
    ifne
        flashLamp(lLock)
    endif
    ldA JokerLitBit
    and >p_flags, X
    ifne
        flashLamp(lJokerSpecial)
    endif
    ldA KickbackLitBit
    and >p_flags, X
    ifne
        lampOn(lKickback)
    endif

    lampOn(lFlush100)

    ldA cEnableFlippers
    jsr turnOnSolenoid

    lampOn(lLeftLane)

    ldA SkillshotTime/TIMER_TICK
    stA skillshotTimer

releaseBall: ; no exit
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

    jsr checkMbInvalid

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
    ifeq ; ball not in trough, ignore
        jmp e_trough
    endif

    ; end ball

    ; display bonus
    jsr showBonus

    ldA >x
    stA pfX

    wait(500)

l_bonus:
    ldX bonusa
    ldY 6
    jsr cleanScore
    ; A = first used position

    cmp bonush-3 
    ifAge ; first digit is 1000s
        ldA >bonush-3 ; is it also zero?
        cmp $31
        bmi e_bonus ; end count

        score1Kx(1)

        ldX bonush-3 ; subtract whatever is left
        ldY 5
    else
        score10Kx(1)

        ldX bonush-4
        ldY 4
    endif
    ldA 1
    jsr subtractScore

    jsr setAtoOtherDisplay
    clC
    adc 12
    tAX
    ldY bonusa
    ldA 8
    jsr copy     

    wait(32)
    jmp l_bonus
e_bonus:

    wait(300)

    ; ball done, store status
    ldX >curPlayer

    ldA >lc(lJack)
    lsr A
    lsr A
    lsr A
    lsr A
    eor 00001111b
    stA p_flush, X
    ldA >lc(lTen)
    ifpl ; ten not flashing -> solid
        ldA 00010000b
        orA p_flush, X
        stA p_flush, X
    endif

    ldA 0
    stA p_flags, X

    ldA lbf(lKickback)
    bit >lc(lKickback)
    ifne
        ldA KickbackLitBit
        orA p_flags, X
        stA p_flags, X
    endif
    ldA lbf(lJokerSpecial)
    bit >lc(lJokerSpecial)
    ifne
        ldA JokerLitBit
        orA p_flags, X
        stA p_flags, X
    endif
    ldA lbf(lLock)
    bit >lc(lLock)
    ifne
        ldA LockLitBit
        orA p_flags, X
        stA p_flags, X
    endif
    
    ; advance game
    
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

e_trough:
    ldA >gFlags
    and ~TroughSettleBit
    stA gFlags

    done()

checkMbInvalid:
    phA 

    ldA >gFlags
    and MbInvalidBit|MultiballBit
    cmp MbInvalidBit|MultiballBit
    ifeq 
        ldA >gFlags
        and ~MbInvalidBit
        stA gFlags

        ldA cLock
        jsr fireSolenoid
    endif

    plA
    rts

resetDrops:
    ldA 11111111b
    stA leftIgnore
    stA rightIgnore
    stA topIgnore

    ldY 125

    ldA cLeftDrop
    jsr fireSolenoidFor
    wait(200)

    ldA cTopDrop
    jsr fireSolenoidFor
    wait(200)

    ldA cRightDrop
    jsr fireSolenoidFor
    wait(200)

    ldA 00000000b
    stA leftIgnore
    stA rightIgnore
    stA topIgnore

    ldA >gFlags
    and ~SpadesTrippedBit
    stA gFlags

    rts

tripBottomDrop:
    ldA IgnoreBottomDropBit
    orA >gFlags
    stA gFlags

    ldA cBottomTrip
    jsr fireSolenoid
    wait(75)

    ldA ~IgnoreBottomDropBit
    and >gFlags
    stA gFlags

    rts

showBonus:
    ldY t_bonus-textStart
    jsr setAtoOtherDisplay
    tAX
    jsr writeText


    jsr setAtoOtherDisplay
    clC
    adc 9
    tAX
    ldA >x
    clC
    adc $30
    stA 0, X

    ldX bonusa
    ldY 6
    jsr cleanScore

    jsr setAtoOtherDisplay
    clC
    adc 12
    tAX
    ldY bonusa
    ldA 8
    jsr copy 

    rts

advBonus:
    ldA >pfX
    phA
    ldA 1
    stA pfX
    ldX bonush-3
    ldY 4
    jsr addScore
    plA
    stA pfX
    rts

leftLane: ; yg
    score10Kx(1)
    jsr advBonus
    ldA lb(lLeftLane)
    bit >lc(lLeftLane)
    ifne 
        jsr advX
    endif

    jsr collectDiamondBonus
    done()
rightLane: ; yh
    score10Kx(1)
    jsr advBonus
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
    ifne ; in mb
        ldA >x
        stA pfX
        asl A
        asl A
        asl A
        asl A
    else
        ldA 1
        stA pfX
        ldA >x
    endif
    stA lc(l1x)

    rts

syncJackpot:
    ldX >curPlayer

    ldA >lc(lJackpot)
    and 00010001b
    stA lc(lJackpot)

    ldA p_jackpot, X
    and 00001110b
    orA >lc(lJackpot)
    stA lc(lJackpot)

    
    ldA p_jackpot, X
    lsr A
    lsr A
    lsr A
    lsr A
    stA lc(ljackpoT)


    ldA p_jackpot
    and 11111110b
    cmp 11111110b
    ifeq ; jackpot spelled
        flashLamp(lJokerSpecial)
        lampOff(lRamp)
    else
        lampOff(lJokerSpecial)
    endif   

    rts

tripDrops:
    ldA 00111000b
    stA leftIgnore
    ldA cLeftTrip
    jsr fireSolenoid
    wait(100)

    ldA 00011000b
    stA topIgnore
    ldA cTopTrip
    jsr fireSolenoid
    wait(100)

    ldA 00111000b
    stA rightIgnore
    ldA cRightTrip
    jsr fireSolenoid
    wait(100)

    rts
    
skillshot: ; yj
    ldA 0
    stA skillshotTimer

    ldA lb(lSkillAll)
    bit >lc(lSkillAll)
    ifne
        ldA >gFlags
        orA SpadesTrippedBit
        stA gFlags

        jsr tripDrops
        
        jsr checkSpades
    endif

    ldA lb(lSkillTop)
    bit >lc(lSkillTop)
    ifne
        ldA >gFlags
        orA SpadesTrippedBit
        stA gFlags

        flashLamp(lAce100k)
        
        ldA 00011000b
        stA topIgnore
        ldA cTopTrip
        jsr fireSolenoid
        
        jsr checkSpades
    endif

    ldA lb(lSkillSpinner)
    bit >lc(lSkillSpinner)
    ifne
        flashLamp(lSpinner)
    endif

    ldA 0
    stA lc(lSkillAll)

    done()
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
    ldA lbf(lAce100k)
    bit >lc(lAce100k)
    ifeq
        score1Kx(5)
    else
        score100Kx(1)
    endif

    lampOn(lAce)

    jmp checkRoyalFlush
checkRoyalFlush:
    ldA >lc(lJack)
    cmp 00001111b
    ifeq ; jack - ace on solid
        ldA >lc(lTen)
        and lbf(lTen)
        cmp lb(lTen)
        ifeq ; ten on solid
            flashLamp(lLock)

            ldA 11110000b
            stA lc(lJack)
            flashLamp(lTen)

            ldA lb(lFlush100)
            bit >lc(lFlush100)
            ifne
                score100Kx(1)
            else
                ldA lb(lFlush250)
                bit >lc(lFlush250)
                ifne
                    score100Kx(2)
                    score10Kx(5)
                else
                    ldA lb(lFlushEb)
                    bit >lc(lFlushEb)
                    ifne
                        score100Kx(5)
                        ldA cKnocker
                        jsr fireSolenoid
                    else
                        jsr special
                    endif
                endif
            endif
            ldA lb(lFlushSpecial)
            bit >lc(lFlushSpecial)
            ifeq
                ldA >lc(lFlushSpecial)
                asl A
                and 00001111b
                stA lc(lFlushSpecial)
            endif
        endif
    endif
    done()

special:
    score100Kx(2)
    ldA cKnocker
    jsr fireSolenoid
    wait(150)
    score100Kx(2)
    ldA cKnocker
    jsr fireSolenoid
    wait(150)
    score100Kx(2)
    ldA cKnocker
    jsr fireSolenoid
    wait(150)
    score100Kx(2)
    ldA cKnocker
    jsr fireSolenoid
    wait(150)
    score100Kx(2)
    ldA cKnocker
    jsr fireSolenoid
    wait(150)
    rts

joker: ; yf
    ldA lbf(lJokerSpecial)
    bit >lc(lJokerSpecial)
    ifne
        jsr special

        ldX >curPlayer
        ldA 0
        stA p_jackpot, X
        jsr syncJackpot
    else
        score1Kx(5)
    endif
    done()
ramp: ; tg
    ldA lbf(lRamp)
    bit >lc(lRamp)
    ifne ; lit
        score100Kx(1)
        
        ldA >rampTimer
        cmp 3000/TIMER_TICK
        ifAlt
            adc 1000/TIMER_TICK
            stA rampTimer
        endif

        ; advance jackpot
        ldX >curPlayer
        ldA p_jackpot, X
        orA 00000001b
        asl A
        stA p_jackpot, X
        jsr syncJackpot
    else
        score10Kx(1)
    endif

    ldA cLeftTrip
    jsr fireSolenoid
    done()
leftSpinner: ; th
rightSpinner: ; tj
    jsr checkMbInvalid
    ldA lbf(lSpinner)
    ifne
        score1Kx(1)
        jsr advBonus
        jsr showBonus
    else
        score100x(1)
        lampOff(lKickback)
    endif
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
    jsr checkMbInvalid

    score1Kx(2)
    jsr advBonus
    lampOn(lKickback)

    ldA cRightTrip
    jsr fireSolenoid
    done()

sling: ; rf
    jsr checkMbInvalid
    score10x(1)
    lampOff(lSpinner)
    lampOff(lAce100k)
    done()

; A = switch number
; X = 'ignore' address to use
; leaves Y = bit in the return
checkDropDown:
    phA

    lsr A
    lsr A
    lsr A
    lsr A ; A = strobe number
    tAY
    ldA 1
l_checkDropDown_bit:
    asl A
    deY
    bne l_checkDropDown_bit
    ; A = bit in the return
    tAY

    and 0, X
    ifne ; already set
        done()
    endif

    tYA
    orA 0, X
    stA 0, X

    plA
    rts

left1: ; qd
left2: ; qf
left3: ; qg
left4: ; qg
left5: ; qh
    ldX leftIgnore
    jsr checkDropDown
    jsr checkMbInvalid

    ; check bottom targets for drop
    cmp $20 ; bottom one
    ifeq 
        ldA 01000000b ; bottom right
        bit >rightIgnore
        ifne
            ldA cBottomDrop
            jsr fireSolenoid
        endif
    endif

    tYA
    and 01000100b ; diamonds
    ifne    
        jsr checkDiamonds
    else
        jsr checkSpades
    endif

    score1Kx(5)

    ldX >leftIgnore
    cpX 01111100b
    ;ifeq 
    ;    ldY 125
    ;    ldA cLeftDrop
    ;    jsr fireSolenoidFor
    ;    wait(200)
    ;    ldA 0
    ;    stA leftIgnore
    ;endif
    jsr checkAllDropsDown
    done()

right1: ; ed
right2: ; ef
right3: ; eg
right4: ; eh
right5: ; ej
    ldX rightIgnore
    jsr checkDropDown
    jsr checkMbInvalid

    ; check bottom targets for drop
    cmp $62 ; bottom one
    ifeq 
        ldA 00000100b ; bottom left
        bit >leftIgnore
        ifne
            ldA cBottomDrop
            jsr fireSolenoid
        endif
    endif

    tYA
    and 01000100b ; diamonds
    ifne    
        jsr checkDiamonds
    else
        jsr checkSpades
    endif

    score1Kx(5)

    ldX >rightIgnore
    cpX 01111100b
    ;ifeq 
    ;    ldY 125
    ;    ldA cRightDrop
    ;    jsr fireSolenoidFor
    ;    wait(200)
    ;    ldA 0
    ;    stA rightIgnore
    ;endif
    jsr checkAllDropsDown
    done()

top1: ; wd
top2: ; wf
top3: ; wg
top4: ; wh
    ldX topIgnore
    jsr checkDropDown
    jsr checkMbInvalid

    tYA
    and 00100100b ; diamonds
    ifne    
        jsr checkDiamonds
    else
        jsr checkSpades
    endif

    score1Kx(5)

    ;ldX >topIgnore
    ;cpX 01111100b
    ;ifeq 
    ;    ldY 125
    ;    ldA cTopDrop
    ;    jsr fireSolenoidFor
    ;    wait(200)
    ;    ldA 0
    ;    stA topIgnore
    ;endif
    jsr checkAllDropsDown
    done()

rts1:
    rts
; see if all diamonds are down
checkDiamonds:
    ldA 01000100b
    and >leftIgnore
    cmp 01000100b
    bne rts1
    ldA 01000100b
    and >rightIgnore
    cmp 01000100b
    bne rts1
    ldA 00100100b
    and >topIgnore
    cmp 00100100b
    bne rts1

    ; all diamonds now down

    ldA MultiballBit
    bit >gFlags
    ifne ; in multiball
        ; ??
    else
        flashLamp(lLock)
    endif

    ldA >diamondh
    cmp $20
    ifne ; diamond bonus active
collectDiamondBonus:
        ldA >gFlags
        orA DiamondCollectBit
        stA gFlags
        wait(750)

l_diamond:
        ldX diamonda
        ldY 6
        jsr cleanScore
        ; A = first used position

        cmp diamondh-3 
        ifAge ; first digit is 1000s
            ldA >diamondh-3 ; is it also zero?
            cmp $31
            bmi e_diamond ; end count

            score1Kx(1)

            ldX diamondh-3 
            ldY 5
        else
            cmp diamondh-4
            ifeq ; first is 10k
                score10Kx(1)

                ldX diamondh-4
                ldY 4
            else
                score100Kx(1)

                ldX diamondh-5
                ldY 3
            endif
        endif
        ldA 1
        jsr subtractScore

        wait(16)
        jmp l_diamond
e_diamond:
        ldA >gFlags
        orA DiamondCollectBit
        stA gFlags

        ldA $20 ; ' '
        ldX diamonda
        ldY diamondh-diamonda+1
        jsr set

        jsr syncDigits
    else ; diamond bonus not active
        ldA $30 ; '0'
        ldX diamonda
        ldY diamondh-diamonda+1
        jsr set
        ldA $32 ; '2'
        stA diamondh-6

        ; increase for spades up
        ldA >pfX
        phA
        ldA 1
        stA pfX

        ldA leftIgnore
        and 00111000b
        jsr addToDiamondBonus
        ldA rightIgnore
        and 00111000b
        jsr addToDiamondBonus
        ldA topIgnore
        and 00011000b
        jsr addToDiamondBonus
        jmp afterAdd
addToDiamondBonus:
        lsr A
        ifeq
            rts
        endif
        ifcc
            phA
            ldX diamonda+2
            ldY 3
            ldA 3
            jsr addScore
            plA
        endif
        jmp addToDiamondBonus
afterAdd:     
        plA
        stA pfX

        jsr resetDrops
        jsr tripDrops

        ldA >gFlags
        and ~DiamondCollectBit
        stA gFlags
    endif
e_check:
    rts
checkSpades:
    ldA 00111000b
    and >leftIgnore
    cmp 00111000b
    bne e_check
    ldA 00111000b
    and >rightIgnore
    cmp 00111000b
    bne e_check
    ldA 00011000b
    and >topIgnore
    cmp 00011000b
    bne e_check

    ; all spades now down
    ldA SpadesTrippedBit
    bit >gFlags
    ifeq ; no spades tripped, light jackpot
        ldX >curPlayer
        ldA 11111110b
        stA p_jackpot, X
        jsr syncJackpot
    else
        flashLamp(lRamp)
        ldA 4000/TIMER_TICK
        stA rampTimer
    endif

    rts
checkAllDropsDown:
    ldA 01111100b
    and >leftIgnore
    cmp 01111100b
    bne e_check
    ldA 01111100b
    and >rightIgnore
    cmp 01111100b
    bne e_check
    ldA 00111100b
    and >topIgnore
    cmp 00111100b
    bne e_check

    jsr resetDrops
    rts



pop: ; wj
    jsr checkMbInvalid
    score1Kx(1)
    lampOff(lSpinner)
    done()

laneChange: ; rj
    ldA lb(lLeftLane)
    bit >lc(lLeftLane)
    ifeq
        lampOn(lLeftLane)
    else
        lampOff(lLeftLane)
    endif
    
    wait(500)
    ldA 1<<2
    bit >strobe0+7
    ifne
        jsr showBonus
    endif

    done()

bottomDrop: ; rd
    ldA IgnoreBottomDropBit
    bit >gFlags
    ifeq
        score10Kx(1)
    endif
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
    jsr checkMbInvalid
    jsr advBonus
    score10Kx(1)
    done()
leftInlane: ; rh
rightInlane ; rj
    jsr checkMbInvalid
    jsr advBonus
    score1Kx(1)
    done()

textStart:
testText:   .text " TEST TEXT \000"
t_switch:   .text " SWITCH XX \000"
t_bonus:    .text "BONUS =  XX XXXXXXXX\000"
t_diamond:  .text "DIAMOND  =  XXXXXXXX\000"
t_dBonus:   .text " BONUS   =  XXXXXXXX\000"

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

; todo
; diamonds down in mb
; flashers?
; diamond values?
; x special?

; all spades crash
; double start