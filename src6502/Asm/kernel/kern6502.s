.import __CARD_START__, __CARDIO__, __ROM0_START__, __ROM1_START__, __SHELL_START__
.import OutputAPI, print, println, printbyte, printword
.import DiskAPI, DetectDisks

ROM0_VER = __ROM0_START__+1
ROM1_VER = __ROM1_START__+1

.rodata

welcomemsg:
  .byte "Kern6502 v0.1 starting...", $0

diskdetect:
  .byte "Detecting Storage: ", $0

disks:
  .byte " disks.", $0

shellsys:
  .byte "SHELL.SYS", $0

romvermsg:
  .byte "Running on ROM Version ", $0

testprompt:
  .byte "Test Prompt: ", $0

echoit:
  .byte "You wrote: ", $0

.bss

buf:
  .res 40

.code

.proc test: near
  lda #<buf
  sta $d100
  lda #>buf
  sta $d101
  lda #<testprompt
  ldx #>testprompt
  ldy #$81
  jsr OutputAPI
  ldy #$82
  jsr OutputAPI
  lda #10
  ldx #10
  ldy #3
  jsr OutputAPI
  lda #<echoit
  ldx #>echoit
  ldy #$80
  jsr OutputAPI
  lda #<buf
  ldx #>buf
  jsr OutputAPI
  ldy #1
  jsr OutputAPI
  pla
  tax
  pla
  jsr printword
  ldy #1
  jsr OutputAPI
  tsx
  txa
  jsr printbyte
  lda #>_exit
  ldx #<_exit-1
  pha
  txa
  pha
  rts
.endproc

.proc _main: near
  lda #0
  ldy #0
  jsr OutputAPI
  lda #32
  ldy #4
  jsr OutputAPI
  lda #<welcomemsg
  ldx #>welcomemsg
  jsr println
  ldy #1
  jsr OutputAPI
  lda #<diskdetect
  ldx #>diskdetect
  jsr print
  jsr DetectDisks
  jsr printbyte
  lda #<disks
  ldx #>disks
  jsr println
  lda #<__SHELL_START__
  sta $d100
  lda #>__SHELL_START__
  sta $d101
  lda #<shellsys
  ldx #>shellsys
  ldy #$d2
  jsr DiskAPI
  bne :+
  pla
  pla
  ldy #>__SHELL_START__
  dey
  tya
  ldx #<__SHELL_START__
  dex
  pha
  txa
  pha
: rts
.endproc

.segment "STARTUP"

kern_start:
  ldx #$ff
  txs
  cld
  jsr _main
_exit:
  lda #$42
  sta $fff0

.segment "HEADER"

  .word $1337
  .byte <kern_start
  .byte $4c
  .addr OutputAPI
  .byte $4c
  .addr DiskAPI
