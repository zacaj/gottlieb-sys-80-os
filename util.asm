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

        ; use curSol as temp storage since it's not needed
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
    ldA #50
    stA U5_timer
    plA
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