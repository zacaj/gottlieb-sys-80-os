
RAM:			.equ $0000  ; thru 017F
stackTop:       .equ $0100
stackBottom:    .equ $017F
curPlayer:      .equ $0000 ; 0-3
curBall:        .equ $0001 ; '1'-'3' or 0 in game over
flags:          .equ $0002 ; UUUUUUU | timer ticked
timer:          .equ $0003 ; decrements to 0 every 16ms
scoreBlinkTimer:.equ $0004 ; blinks the player's score off/on
pfX:            .equ $0005 ; multiplies scoring
scoreTemp:      .equ $0006 ; stores pf x during score calculation
queueTemp:      .equ $000C ; D
nextQueue:      .equ $000E ; address within queueLow thru queueLowEnd.  the next queue entry to check and maybe run
curQueue:       .equ $000F ; address within queueLow thru queueLowEnd.  the queue entry following the most recently populated
lamp1:          .equ $0011 ; lower nibble: lamp state.  upper nibble: flash lamps if set
lamp12:         .equ lamp1 + 11
curLamp:        .equ $001D ; 1-12
lampTemp:       .equ $001E
curSol:         .equ $001F ; currently firing solenoid or 0
#define lampSol(n,c,x) (c<<4)|(x) ; represents a solenoid driven by a lamp, pass to turnOnSolenoid, etc.  n = lamp number.  c=column, 1-12.  x = the bit (0001b thru 1000b).
#define lc(n) (lamp1 + (n/4)) ; gets a lamp 'column', 1-12
#define lb(n) (1b<<(n%4)) ; the bit for this lamp, to be stored in lc(1-12)
#define lf(n) (10000b<<(n%4)) ; the bit for this lamp to flash, to be stored in lc(1-12)
#define lbf(n) (10001b<<(n%4)) ; the bit for this lamp to be on and flash, to be stored in lc(1-12)

;p1a:            .equ $0020
;p1f:            .equ $0025
;p2a:            .equ $0026
;p2f:            .equ $002C
;p3a:            .equ $002D
;p3f:            .equ $0032
;p4a:            .equ $0033
;p4f:            .equ $0038
;digitsToRefresh:       .equ $0039 ;  0-15
digitA:         .equ $0020
digitB:         .equ $0021
digit1:         .equ $0022 ; ascii, beginning of upper display
digit21:        .equ digit1+22 ; beginning of lower display
digit40:        .equ $004C ; end of lower display
curSwitch:      .equ $004E ; 0 - 7, the next row to strobe
refresh_dispBit:.equ $004F
switchTemp:     .equ $004D
switchY:        .equ $004C
strobe0:        .equ $0050 ; status of switches in strobe 0, lsb = return 0
strobe7:        .equ $0057
sswitch1:       .equ $0058 ; used for settling switches, same contents as strobe
sswitch8:       .equ $005F
queueLow:       .equ $0060 ; LSB of address to jump to
queueLowEnd:    .equ $0067 ; upper end of array
queueHigh:      .equ $0070 ; MSB of address to jump to.  queue entry is only valid if this is non-zero
queueLeft:      .equ $0068 ; time left before activating this item (runs at 0)
queueA:         .equ $0078 ; value to load into A before jump
p1a:            .equ $0080 ; 10mil
p1h:            .equ $0087 ; 1s
p2a:            .equ $0088 ; 10mil
p2h:            .equ $008F ; 1s
p3a:            .equ $0090 ; 10mil
p3h:            .equ $0097 ; 1s
p4a:            .equ $0098 ; 10mil
p4h:            .equ $009F ; 1s
gameRAM:        .equ $00A0 ; and on


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
U5_timer:       .equ U5+$1F
U5_irq:         .equ U5+$05
U5_disable:     .equ U5+$14
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

#define TIMER_TICK 16 ; ms, how often timer fires
#define SWITCH_SPEED 2 ; how fast to run the switch interrupt (1 = 1/850th of a second?)
#define TIMER_ADJUST 6 ; how many switch interrupts = 16ms