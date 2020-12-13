
RAM:			.equ $0000  ; thru 017F
stackBottom:    .equ $017F
lamp1:          .equ $0010
lamp12:         .equ lamp1 + 11
curLamp:        .equ $001C ; 1-12
lampTemp:       .equ $001E
;p1a:            .equ $0020
;p1f:            .equ $0025
;p2a:            .equ $0026
;p2f:            .equ $002C
;p3a:            .equ $002D
;p3f:            .equ $0032
;p4a:            .equ $0033
;p4f:            .equ $0038
;curDigit:       .equ $0039 ;  0-15
digitBit:       .equ $001F
digitA:         .equ $0020
digitB:         .equ $0021
digit1:         .equ $0022
digit21:        .equ digit1+22
digit40:        .equ $004C
curDigit:       .equ $004D ; 0 - 21 -> ignore, ignore, digit1 - digit 20
curSwitch:      .equ $004E ; 0 - 7
switchTemp:     .equ $004D
switchY:        .equ $004C
switch1:        .equ $0050
switch8:        .equ $0057
sswitch1:       .equ $0058
sswitch8:       .equ $005F
queueLow:       .equ $0060
queueLowEnd:    .equ $0067
queueHigh:      .equ $0070
queueLeft:      .equ $0068 ; 
curQueueStart:  .equ $007E
curQueueEnd:    .equ $007F
queueTemp:      .equ $007C ; +


U4:             .equ $0200  ; 0200-021F	U4 registers, switch matrixU5a:            .equ U5+$00
U4a:            .equ U4+$00
U4a_dir:        .equ U4+$01
U4b:            .equ U4+$02
U4b_dir:        .equ U4+$03
U4_timer:       .equ U4+$1F
U4_irq:         .equ U4+$05
strobes:        .equ U4b
returns:        .equ U4a
U5:             .equ $0280   ; 0280-029F	U5 registers, display
U5a:            .equ U5+$00
U5a_dir:        .equ U5+$01
U5b:            .equ U5+$02
U5b_dir:        .equ U5+$03
U5_timer:       .equ U5+$1E
U5_irq:         .equ U5+$05
digitData:      .equ U5a ; 0-3: select digit 0-15.  4-6: strobe segment group A-C.  7: ignore
digitDir:       .equ U5a_dir
segmentData:    .equ U5b ; 0-3: BCD segments. 4-6: 1s segment for segment group A-C. 7: sw enable (keep low)
segmentDir:     .equ U5b_dir
U6:             .equ $0300; 0300-031F	U6 registers, solenoids/sounds/dip control
U6a:            .equ U6+$00
U6a_dir:        .equ U6+$01
U6b:            .equ U6+$02
U6b_dir:        .equ U6+$03
U6_timer:       .equ U6+$1F
U6_irq:         .equ U6+$05
lampData:       .equ U6b
lampDir:        .equ U6b_dir
solData:        .equ U6a
solDir:         .equ U6a_dir


U2:             .equ $2000
U3:             .equ $3000
U3end:          .equ $3FFF