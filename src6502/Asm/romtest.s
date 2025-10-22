.import __ROM0_START__

_print = __ROM0_START__+2

.rodata

romtestmsg:
  .byte "This is a test of the secondary ROM loading mechanic.", $0

.segment "STARTUP"

jmp res_vec

.code

res_vec:
  lda #<romtestmsg
  ldx #>romtestmsg
  jsr _print
  rts

.segment "HEADER"

.byte <res_vec, $01, $4c
.addr _print
.byte "WebROM$"
