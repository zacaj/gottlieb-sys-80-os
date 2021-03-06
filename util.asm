
#define pushAll \ phA
#defcont        \ tXA
#defcont        \ phA
#defcont        \ tYA
#defcont        \ phA

#define pullAll \ plA
#defcont        \ tAY
#defcont        \ plA
#defcont        \ tAX
#defcont        \ plA

#define pushAX  \ phA
#defcont        \ tXA
#defcont        \ phA

#define pullAX  \ plA
#defcont        \ tAX
#defcont        \ plA


turnOffCurSolenoid:
    pushAX

    ldA 11110000b
    bit >curSol
    ifne
        ldA >curSol ; cur sol = BANK BITS
        lsr A
        lsr A
        lsr A
        lsr A
        tAX ; X = ____ BANK

        ; update lamps in mem
        ldA >curSol
        and 00001111b
        eor lamp1-1, X
        stA lamp1-1, X

        ; update board
        ; load in BITS
        and 00001111b
        stA lampData

        ; use curSol as temp storage since it's not needed anymore
        ldA >curSol
        and 11110000b
        stA curSol

        ; clock the BANK
        ldA lamp1-1, X
        orA >curSol
        stA lampData
    endif

    ldA >solData
    orA 11110000b
    stA solData

    ldA 00000000b
    stA curSol

    pullAX
    rts

; A: solenoid to turn off
turnOffSolenoid:
    pushAX
    tSX
    ldA $100+2, X

    ldX >curSol
    stA curSol
    jsr turnOffCurSolenoid
    stX curSol

    pullAX
    rts

; A: solenoid to turn on
fireSolenoid:
    phA
    ldA 60
    stA U5_timer
    plA
    jsr turnOnSolenoid
    stA curSol
    rts

; A: solenoid to turn on
; Y: time to fire it for
fireSolenoidFor:
    stY U5_timer
    jsr turnOnSolenoid
    stA curSol
    rts

; A: solenoid to turn on
turnOnSolenoid:
    jsr turnOffCurSolenoid

    phA

    stA curSol

    tXA
    phA
    ldA 11110000b
    bit >curSol
    ifne ; lamp
        ldA >curSol
        lsr A
        lsr A
        lsr A
        lsr A
        tAX
        ldA >curSol
        and 00001111b
        ; update lamp mem
        orA lamp1-1, X
        stA lamp1-1, X

        ; update board
        and 00001111b
        stA lampData
        orA >curSol
        stA lampData
    else
        ldA >curSol
        cmp 9
        ifeq
            ldA >solData
            and 01111111b
            stA solData
        else 
            cmp 5
            seC
            ifAge
                sbc 5
                asl A
                asl A
            else
                sbc 1
            endif
            eor 00001111b
            ; A = bit 0-3
            orA 11110000b
            stA solData
            ldA >curSol
            cmp 5
            ifAge
                ldA 01000000b
            else
                ldA 00100000b
            endif
            eor >solData
            stA solData
        endif       
    endif

    ldA 0
    stA curSol

    plA
    tAX
    plA
    
    rts

playSound:
    seI
    phA

    and 11110000b
    ifeq ; lamp off
        ldA >lamp1+1
        and 00001110b
    else ; lamp on
        ldA >lamp1+1
        and 00001111b
        orA 00000001b
    endif
    stA lampData
    orA $20
    stA lampData

    jsr turnOffCurSolenoid

    plA

    orA 11100000b
    and 11101111b
    stA solData
    ldA $FF
    stA solData

    clI
    rts

; adds score * pfX
; A: amount to add (1-9)
; X: address to add to
; Y: max number of digits to affect
addScore:
    phA
    ldA >pfX
    stA scoreTemp
    plA
    pushAll
l_addScoreX:
    ; restore values
    tSX
    ldA $100+3, X ; A
    phA
    ldA $100+1, X ; Y
    phA ; push Y again
    tXA
    tAY
    ldX $100+2, Y ; X
    plA
    tAY
    plA

l_addScore_overflow:
    ; check if blank
    phA
    ldA 0, X
    cmp $20 ; ' 
    ifeq
        ldA $30
        stA 0, X
    endif
    plA

    ; do the add
    clC
    adc 0, X
    cmp $39+1 ; '9' + 1
    ifAge
        ; overflowed
        seC
        sbc 10
        stA 0, X
        deX
        deY
        beq e_addScore

        ; carry to next digit
        ldA 1
        jmp l_addScore_overflow
    else
        stA 0, X
    endif

e_addScore:
    dec scoreTemp
    bne l_addScoreX

    pullAll
    rts

; A: amount to subtract (1-9)
; X: address to subtract from
; Y: max number of digits to affect
subtractScore:
    ; negate A
    stA scoreTemp
    ldA 255
    seC
    sbc >scoreTemp

    ; check if blank
    phA
    ldA 0, X
    cmp $20 ; ' 
    ifeq
        ldA $30
        stA 0, X
    endif
    plA

    ; do the math
    seC
    adc 0, X
    cmp $30 ; '0'
    ifAlt
        ; overflowed
        clC
        adc 10
        stA 0, X
        deX
        deY
        beq e_subScore

        ; carry to next digit
        ldA 1
        jmp subtractScore
    else
        stA 0, X
    endif

e_subScore:
    rts

; Y: source
; X: dest
; A: amount
copy:
    phA
    ldA 0, Y
    stA 0, X
    inX
    inY
    plA
    seC
    sbc 1
    bne copy
    rts

; X: dest
; Y: amount
; A: value
set:
    stA 0, X
    inX
    deY
    bne set
    rts

setXToCurPlayer10:
    phA
    ldA >curPlayer
    asl A
    asl A
    asl A
    adc p1h-1
    tAX
    plA
    rts


#define score10x(a) ldA 0+a \ jsr score10xA
score10xA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    ldY 7
    jsr addScore
    pullAll
    rts
#define score100x(a) ldA 0+a \ jsr score100xA
score100xA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    deX
    ldY 6
    jsr addScore
    pullAll
    rts
#define score1Kx(a) ldA 0+a \ jsr score1kxA
score1kxA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    deX
    deX
    ldY 5
    jsr addScore
    pullAll
    rts
#define score10Kx(a) ldA 0+a \ jsr score10kxA
score10kxA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    deX
    deX
    deX
    ldY 4
    jsr addScore

    pullAll
    rts
#define score100Kx(a) ldA 0+a \ jsr score100kxA
score100kxA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    deX
    deX
    deX
    deX
    ldY 3
    jsr addScore

    pullAll
    rts
#define score1Mx(a) ldA 0+a \ jsr score1MxA
score1MxA:
    pushAll
    tSX
    ldA $100+3, X
    jsr setXToCurPlayer10
    deX
    deX
    deX
    deX
    deX
    ldY 2
    jsr addScore

    pullAll
    rts


; X = starting position
; Y = max number of bytes to affect
; leaves A = first >0 position, or = X+Y if no >0 found
cleanScore:
    deX
    inY
    ; step 1, remove 0s until >0 is found
l_leadingZero:
    inX
    deY
    ifeq
        tXA
        phA
        jmp e_cleanScore
    endif
    ldA 0, X
    cmp $30 ; '0'
    ifeq
        ldA $20 ; ' '
        stA 0, X
    endif
    cmp $20 ; ' '
    beq l_leadingZero
    ; X = first >0 
    tXA
    phA
    ; step 2, add 0s where empty
l_emtpy:
    ldA 0, X
    cmp $20 ; ' '
    ifeq
        ldA $30 ; '0'
        stA 0, X
    endif
    inX
    deY
    bne l_emtpy

e_cleanScore:
    plA
    rts

#define done() jmp afterQueueRun

setXtoEmptyQueue:
    ldX >curQueue
    phA
l_findQueue:
    ldA queueHigh-queueLow, X
    beq foundQueue
    cpX queueLowEnd
    ifeq
        ldX queueLow
    else
        inX
    endif
    jmp l_findQueue
foundQueue: ; X = valid queue position
    plA
    rts

#define wait(t) \ phA
#defcont        \ ldA t/TIMER_TICK
#defcont        \ jsr _wait

_wait:
    jsr setXtoEmptyQueue
    stA queueLeft-queueLow, X
    plA 
    clC
    adc 1
    stA 0, X
    plA 
    adc 0
    stA queueHigh-queueLow, X
    plA 
    stA queueA-queueLow, X

    ; increment queue
    cpX queueLowEnd
    ifeq
        ldX queueLow
    else
        inX
    endif
    stX curQueue

    jmp afterQueueRun

#define lampOn(n) \ ldA >lc(n)
#defcont          \ orA lb(n)
#defcont          \ and ~lf(n)
#defcont          \ stA lc(n)

#define flashLamp(n) \ ldA >lc(n)
#defcont             \ orA lf(n)
#defcont             \ stA lc(n)

#define lampOff(n)   \ ldA >lc(n)
#defcont             \ and ~lbf(n)
#defcont             \ stA lc(n)
