.import __CARD_START__, __CARDIO__, __ROM0_START__, __RAM3_START__

_print = __ROM0_START__+2
print = __ROM0_START__+3

OUTPUT = __CARD_START__
OUT_BUF = OUTPUT+2

OUT_TYP = __CARDIO__

BIN_ADDR = $5000

BIN_FILE = $ff00

.zeropage

DISK: .res 2, $00
ENV: .res 2, $00

.bss

envfile: .res 80, $00

.rodata

crlf:
  .byte $0d, $0a, $0

br:
  .byte "<br/>", $0

welcomemsg:
  .byte "Web6502 Bootloader v0.1", $0

scanmsg:
  .byte " * Scanning Card Slots...", $0

slotmsg:
  .byte " in Slot #", $0

unknownmsg:
  .byte "   - Unknown Card", $0

vt100card:
  .byte "   - VT100 Termminal Output Card", $0

testcard:
  .byte "   - DEBUG/Test Card", $0

termcard:
  .byte "   - jQuery Terminal Output Card", $0

domcard:
  .byte "   - HTML DOM Element Output Card", $0

cffacard:
  .byte "   - CFFA1 Storage Card", $0

envcard:
  .byte "   - Environment Card", $0

wdcard:
  .byte "   - WebDisk Card", $0

blogcard:
  .byte "   - Blog Interface Card", $0

routercard:
  .byte "   - Router Card", $0

canvascard:
  .byte "   - HTML5 Canvas Card", $0

tablecard:
  .byte "   - Data Table Card", $0

envrun:
  .byte "boot", $0

loadingmsg:
  .byte " * Loading: ", $0

failmsg:
  .byte ", failed to load program.", $0

startmsg:
  .byte ", starting program...", $0

bootfail:
  .byte " *** Could not determine how to boot 6502 system. ***", $0

kernsys:
  .byte "KERNEL.SYS", $0

.code

.proc newline: near
  lda OUT_TYP
  cmp #$80
  bne :+
  lda #<br
  ldx #>br
  jmp (print)
: cmp #$76
  bne :+
  lda #<crlf
  ldx #>crlf
  jmp (print)
: rts
.endproc

.proc _println: near
  jsr _print
  jmp newline
.endproc

.proc print_slot: near
  jsr _print
  lda #<slotmsg
  ldx #>slotmsg
  jsr _print
  sty OUT_BUF
  lda #$90
  sta OUTPUT
  jmp newline
.endproc

.proc print_card: near
  cmp #$76
  bne :+
  lda #<vt100card
  ldx #>vt100card
  jmp print_slot
: cmp #$42
  bne :+
  lda #<termcard
  ldx #>termcard
  jmp print_slot
: cmp #$80
  bne :+
  lda #<domcard
  ldx #>domcard
  jmp print_slot
: cmp #$99
  bne :+
  lda #<testcard
  ldx #>testcard
  jmp print_slot
: cmp #$cf
  bne :+
  lda #<cffacard
  ldx #>cffacard
  jmp print_slot
: cmp #$1e
  bne :+
  lda #<envcard
  ldx #>envcard
  jmp print_slot
: cmp #$d6
  bne :+
  lda #<wdcard
  ldx #>wdcard
  jmp print_slot
: cmp #$8f
  bne :+
  lda #<blogcard
  ldx #>blogcard
  jmp print_slot
: cmp #$43
  bne :+
  lda #<routercard
  ldx #>routercard
  jmp print_slot
: cmp #$2d
  bne :+
  lda #<canvascard
  ldx #>canvascard
  jmp print_slot
: cmp #$da
  bne :+
  lda #<tablecard
  ldx #>tablecard
  jmp print_slot
: lda #<unknownmsg
  ldx #>unknownmsg
  jmp print_slot
.endproc

.proc calc_card: near
  tya
  clc
  adc #$c0
  rts
.endproc

.proc init_card: near
  cmp #$d6
  bne :+
  jsr calc_card
  sta DISK+1
  rts
: cmp #$1e
  bne :+
  jsr calc_card
  sta ENV+1
: rts
.endproc

.proc scan_cards: near
  lda #<scanmsg
  ldx #>scanmsg
  jsr _println
  ldy #$0
: lda __CARDIO__, Y
  beq :+
  pha
  jsr print_card
  pla
  jsr init_card
: iny
  cpy #$8
  bne :--
  rts
.endproc

start_ldr:
  ldy #0
  lda #$d2
  sta (DISK), Y
: lda (DISK), Y
  bne :-
  iny
  lda (DISK), Y
  bne :+
  lda #<startmsg
  ldx #>startmsg
  jsr _println
jmpldr:
  jmp BIN_ADDR
: lda #<failmsg
  ldx #>failmsg
  jmp _println

.proc check_env: near
  ldy #2
  lda #<envrun
  sta (ENV), Y
  iny
  lda #>envrun
  sta (ENV), Y
  iny
  lda #<envfile
  sta (ENV), Y
  iny
  lda #>envfile
  sta (ENV), Y
  ldy #0
  lda #$e1
  sta (ENV), Y
  iny
  lda (ENV), Y
  beq :+
  rts
: lda #<loadingmsg
  ldx #>loadingmsg
  jsr _print
  ldy #2
  lda #<envfile
  sta (DISK), Y
  sta OUT_BUF
  iny
  lda #>envfile
  sta (DISK), Y
  sta OUT_BUF+1
  iny
  lda #<BIN_ADDR
  sta (DISK), Y
  iny
  lda #>BIN_ADDR
  sta (DISK), Y
  lda #$80
  sta OUTPUT
  jmp start_ldr
.endproc

.proc check_ldr: near
  lda BIN_FILE
  bne :+
  rts
: lda #<loadingmsg
  ldx #>loadingmsg
  jsr _print
  ldy #2
  lda #<BIN_FILE
  sta (DISK), Y
  sta OUT_BUF
  iny
  lda #>BIN_FILE
  sta (DISK), Y
  sta OUT_BUF+1
  iny
  lda #<BIN_ADDR
  sta (DISK), Y
  iny
  lda #>BIN_ADDR
  sta (DISK), Y
  lda #$80
  sta OUTPUT
  jmp start_ldr
.endproc

.proc kernel: near
  lda #<loadingmsg
  ldx #>loadingmsg
  jsr _print
  ldy #2
  lda #<kernsys
  sta (DISK), Y
  sta OUT_BUF
  iny
  lda #>kernsys
  sta (DISK), Y
  sta OUT_BUF+1
  iny
  lda #<__RAM3_START__
  sta (DISK), Y
  sta jmpldr+1
  iny
  lda #>__RAM3_START__
  sta (DISK), Y
  sta jmpldr+2
  lda #$80
  sta OUTPUT
  jmp start_ldr
.endproc

.proc _main: near
  jsr newline
  lda #<welcomemsg
  ldx #>welcomemsg
  jsr _println
  jsr scan_cards
  lda DISK+1
  beq :++
  lda ENV+1
  beq :+
  jsr check_env
: lda DISK+1
  beq :+
  jsr check_ldr
  jmp kernel
: lda #<bootfail
  ldx #>bootfail
  jsr _println
  rts
.endproc

.segment "STARTUP"

ldx #$FF
txs
cld
lda #$00
sta DISK
sta DISK+1
sta ENV
sta ENV+1
jsr _main
lda #$42
sta $fff0
