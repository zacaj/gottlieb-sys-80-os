refreshDisplay:
l_refresh:
    ; load lower nibble
    ldA 0, X
    and #00001111b
    orA #00110000b
    stA U5b

    ; latch it
    ldA U5a
    orA #00010000b
    stA U5a
    and #11101111b
    stA U5a  

    ; load high nibble
    ldA 0, X
    and #11110000b
    lsr A
    lsr A
    lsr A
    lsr A
    orA #00110000b
    stA U5b

    ; latch it
    ldA U5a
    orA #00100000b
    stA U5a
    and #11011111b
    stA U5a  
    
    ; latch digit to display
    ldA U5b
    eor refresh_dispBit
    stA U5b
    orA refresh_dispBit
    stA U5b

    inX
    deY
    bne l_refresh

    rts

refreshDisplays:
    phA
    tXA
    phA
    tYA
    phA
    
    ldA #00010000b
    stA refresh_dispBit
    ldX #digit1-2
    ldY #22
    jsr refreshDisplay

    ldA #00100000b
    stA refresh_dispBit
    ldX #digit21-2
    ldY #22
    jsr refreshDisplay

    plA
    tAY
    plA
    tAX
    plA
    rts

initSys80B:
    
; reset display controller
    ldA #01111111b    ; reset on, LD off
    stA U5b

    and #10110000b
    stA U5b

; init parallel mode
    ; bring D4-7 high
    ldA U5b
    orA #00001111b
    stA U5b
    ; latch it
    ldA U5a
    orA #00110000b
    stA U5a
    and #11001111b
    stA U5a  
    ; lower  D4-7
    ldA U5b
    and #11110000b
    stA U5b
    ; latch it
    ldA U5a
    orA #00110000b
    stA U5a
    and #11001111b
    stA U5a  

; init display chips    
    ldA #$01
    stA digit1-2
    ldA #$08 ; normal display mode
    stA digit1-1
    
    ldA #$01
    stA digit1-0
    ldA #$94 ; 20 digits
    stA digit1+1
    
    ldA #$01
    stA digit1+2
    ldA #$06 ; digit time 32
    stA digit1+3
    
    ldA #$01
    stA digit1+4
    ldA #$5C ; digit time 32
    stA digit1+5

    ldA #$01
    stA digit1+6
    ldA #$0E ; start display
    stA digit1+7

; init  displays
    ldA #00110000b
    stA refresh_dispBit
    ldX #digit1-2
    ldY #10
    jsr refreshDisplay

; set initial display commands
    ldA #$01
    stA digit1-2
    stA digit21-2
    ldA #$C0
    stA digit1-1
    stA digit21-1

    jsr refreshDisplays

    rts

; X: address in digit# to write to
; Y: location of text relative to textStart
; text must be null terminated (\000)
writeText:
    phA
l_text:
    ldA textStart, Y
    beq e_text
    stA 0, X
    inX
    inY
    bne l_text
e_text:
    plA
    rts

setAtoCurPlayerFirstDigit:
    ldA curPlayer
    cmp #0
    ifeq
        ldA #digit1
    else 
        cmp #1
        ifeq 
            ldA #digit1+12
        else
            cmp #2
            ifeq 
                ldA #digit21
            else
                ldA #digit21+12
            endif
        endif
    endif

    rts

setAtoOtherDisplay:
    ldA #00000010b
    bit curPlayer
    ifeq ; player 1 or 2, top display
        ldA #digit21
    else
        ldA #digit1
    endif
    rts


syncDigits:
    ldA #$20 ; ' '
    stA digit1+8
    stA digit1+9
    stA digit1+11
    stA digit21+8
    stA digit21+9
    stA digit21+11
    ldA curBall
    stA digit1+10

    ldY #p1a
    ldX #digit1
    ldA #8
    jsr copy
    ldY #p2a
    ldX #digit1+12
    ldA #8
    jsr copy
    ldY #p3a
    ldX #digit21
    ldA #8
    jsr copy
    ldY #p4a
    ldX #digit21+12
    ldA #8
    jsr copy

    rts

syncCurPlayer:
    jsr setAtoCurPlayerFirstDigit
    tAX


    ; copy player

    ldA curPlayer
    asl A
    asl A
    asl A
    adc #p1a
    phA ; A = cur player 10 mil digit

    ; fix blank positions
    tAX ; X = cur player 10 mil digit
    ldY #p1h-p1a+1
l_findFirstDigit:
    ldA 0, X
    inX
    deY
    cmp #$20 ; ' '
    beq l_findFirstDigit
    ; X = first filled in digit+1
l_zeroBlankDigits:
    ldA 0, X
    cmp #$20 ; ' '
    ifeq
        ldA #$30 ; '0'
        stA 0, X
    endif
    inX
    deY
    bne l_zeroBlankDigits
    
    plA
    tAY
    jsr setAtoCurPlayerFirstDigit
    tAX

    ldA #8
    jsr copy
    rts

handleBlinkScore:
    dec scoreBlinkTimer
    ifeq
        jsr setAtoCurPlayerFirstDigit
        tAX
        clC
        adc #7 ; get to 1s digit
        tAY


        ldA 0, Y
        cmp #$20 ; ' '
        ifeq ; currently blank
            ldA curPlayer
            asl A
            asl A
            asl A
            adc #p1a
            tAY ; X = start of player score
            ldA #8
            jsr copy

            ldA #800/TIMER_TICK
        else
            ldA #$20 ; ' '
            ldY #8
            jsr set

            ldA #200/TIMER_TICK
        endif

        stA scoreBlinkTimer
        jsr refreshDisplays
    endif

    rts

