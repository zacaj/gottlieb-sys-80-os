
RAM:			.equ $0000  ; thru 017F
stackBottom:    .equ $017F
lamp1:          .equ $0010
lamp12:         .equ lamp1 + 11
lampTimer:      .equ $001C

U4:             .equ $0200  ; 0200-021F	U4 registers, switch matrix
U5:             .equ $0280   ; 0280-029F	U5 registers, display
U6:             .equ $0300; 0300-031F	U6 registers, solenoids/sounds/dip control
U6a:            .equ U6+$00
U6a_dir:        .equ U6+$01
U6b:            .equ U6+$02
U6b_dir:        .equ U6+$03
lampData:       .equ U6b
lampDir:        .equ U6b_dir
solData:        .equ U6a
solDir:         .equ U6a_dir

U2:             .equ $2000
U3:             .equ $3000
U3end:          .equ $3FFF