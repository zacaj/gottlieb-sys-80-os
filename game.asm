
.org U3 + (64*2)
nothing:
    nop
    jmp afterQueueRun

right1:
    nop
    jmp afterQueueRun

joker: 
    nop
    ldA lamp1
    eor #00001111b
    stA lamp1
    jmp afterQueueRun


textStart:
testText: .text " TEST TEXT \000"
t_switch: .text " SWITCH XX \000"

.org U3
switchCallbacks:
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw right1 \.dw nothing \.dw nothing \.dw joker \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing
    .dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing \.dw nothing