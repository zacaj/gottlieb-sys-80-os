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
    eor digitBit
    stA U5b
    orA digitBit
    stA U5b

    inX
    dec curDigit
    bne l_refresh

    rts

refreshDisplays:
    phA
    
    ldA #00010000b
    stA digitBit
    ldX #digit1-2
    ldA #22
    stA curDigit
    jsr refreshDisplay

    ldA #00100000b
    stA digitBit
    ldX #digit21-2
    ldA #22
    stA curDigit
    jsr refreshDisplay

    plA
    rts