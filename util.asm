turnOffCurSolenoid:
    phA
    tXA
    phA

    ldA #11110000b
    bit curSol
    ifne
        ldA curSol ; cur sol = BANK BITS
        lsr A
        lsr A
        lsr A
        lsr A
        tAX ; X = ____ BANK

        ; update lamps in mem
        ldA curSol
        and #00001111b
        eor lamp1-1, X
        stA lamp1-1, X

        ; update board
        ; load in BITS
        and #00001111b
        stA lampData

        ; use curSol as temp storage since it's not needed anymore
        ldA curSol
        and #11110000b
        stA curSol

        ; clock the BANK
        ldA lamp1-1, X
        orA curSol
        stA lampData
    endif

    ldA solData
    orA #11100000b
    stA solData

    ldA #00000000b
    stA curSol

    plA
    tAX
    plA
    rts

; A: solenoid to turn off
turnOffSolenoid:
    phA
    tXA
    phA

    ldX curSol
    jsr turnOffCurSolenoid
    stA curSol

; A: solenoid to turn on
fireSolenoid:
    phA
    ldA #60
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
    ldA #11110000b
    bit curSol
    ifne ; lamp
        ldA curSol
        lsr A
        lsr A
        lsr A
        lsr A
        tAX
        ldA curSol
        and #00001111b
        ; update lamp mem
        orA lamp1-1, X
        stA lamp1-1, X

        ; update board
        and #00001111b
        stA lampData
        orA curSol
        stA lampData
    else
        ldA curSol
        cmp #9
        ifeq
            ldA solData
            and #01111111b
            stA solData
        else 
            cmp #5
            seC
            ifAge
                sbc #5
                asl A
                asl A
            else
                sbc #1
            endif
            eor #00001111b
            ; A = bit 0-3
            orA #11100000b
            stA solData
            ldA curSol
            cmp #5
            ifAge
                ldA #01000000b
            else
                ldA #00100000b
            endif
            eor solData
            stA solData
        endif       
    endif

    ldA #0
    stA curSol

    plA
    tAX
    plA
    
    rts

; A: amount to add (1-9)
; X: address in digit1-40 to add to
; Y: max number of digits to affect
addScore:
    ; check if blank
    phA
    ldA 0, X
    cmp #$20 ; ' 
    ifeq
        ldA #$30
        stA 0, X
    endif
    plA

    ; do the add
    clC
    adc 0, X
    cmp #$39+1 ; '9' + 1
    ifAge
        ; overflowed
        seC
        sbc #10
        stA 0, X
        deX
        deY
        beq e_addScore

        ; carry to next digit
        ldA #1
        jmp addScore
    else
        stA 0, X
    endif

e_addScore:
    rts
