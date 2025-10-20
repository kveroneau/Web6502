.import __CARD_START__, __CARDIO__, __RAM0_START__

OUTPUT = __CARD_START__
OUT_BUF = OUTPUT+2
CIN = OUTPUT+4

DISK = __CARD_START__+$600
DISK_ERR = DISK+1
DISK_BUF = DISK+2
DISK_ADR = DISK+4

OUT_TYP = __CARDIO__
DISK_TYP = __CARDIO__+6

BIN_ADDR = $5000

.rodata

bootfile:
  .byte "WEB6502.SYS", $0

welcomemsg:
  .byte "Web6502 BootROM v0.1", $0

booterr:
  .byte ", Boot Error, cannot load WEB6502.SYS!", $0

bootmsg:
  .byte ", Loading WEB6502.SYS...", $0

.zeropage

ptr: .res 2, $00

.code

.proc _webdisk: near
  cmp #$d6
  beq :+
  rts
: lda #<bootfile
  sta DISK_BUF
  lda #>bootfile
  sta DISK_BUF+1
  lda #<__RAM0_START__
  sta DISK_ADR
  lda #>__RAM0_START__
  sta DISK_ADR+1
  lda #$d2
  sta DISK
: lda DISK
  bne :-
  lda DISK_ERR
  bne :+
  lda #<bootmsg
  ldx #>bootmsg
  jsr _print
  jmp (DISK_ADR)
: rts
.endproc

.proc _bootsys: near
  lda DISK_TYP
  jsr _webdisk
  lda BIN_ADDR
  beq :+
  jmp BIN_ADDR
: lda #<OUT_TYP
  sta ptr
  lda #>OUT_TYP
  sta ptr+1
  ldy #0
  lda (ptr),Y
  cmp #$76
  bne :+
  lda #<booterr
  ldx #>booterr
  jsr _print
: lda #$42
  sta $fff0
.endproc

.proc _print: near
  sta OUT_BUF
  stx OUT_BUF+1
  lda #$80
  sta OUTPUT
  rts
.endproc

.segment "STARTUP"

res_vec:
ldx #$FF
txs
cld
lda #<welcomemsg
ldx #>welcomemsg
jsr _print
jmp _bootsys

.segment "HEADER"

.byte <res_vec, $01, $4c
.addr _print
.byte "WebROM$"
