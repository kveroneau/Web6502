.import popax
.export _InitWebDisk, _WD_LoadFile, _WD_ExecPRG, _WD_LoadTextFile, _WD_LoadMarkdown

.zeropage

WEBDISK_CARD: .addr $0000

.code

.proc _InitWebDisk: near
  clc
  adc #$c0
  sta WEBDISK_CARD+1
  lda #$00
  sta WEBDISK_CARD
  rts
.endproc

.proc SetCardData: near
  ldy #$4
  sta (WEBDISK_CARD), Y
  iny
  txa
  sta (WEBDISK_CARD), Y
  jsr popax
  ldy #$2
  sta (WEBDISK_CARD), Y
  iny
  txa
  sta (WEBDISK_CARD), Y
  ldy #$0
  rts
.endproc

.proc CardOp: near
  sta (WEBDISK_CARD), Y
: lda (WEBDISK_CARD), Y
  bne :-
  iny
  lda (WEBDISK_CARD), Y
  rts
.endproc

.proc _WD_LoadFile: near
  jsr SetCardData
  lda #$d2
  jmp CardOp
.endproc

StartPRG:
  jmp ($c000)

.proc _WD_ExecPRG: near
  ldy #$2
  sta (WEBDISK_CARD), Y
  iny
  txa
  sta (WEBDISK_CARD), Y
  ldy #$0
  lda #$d4
  sta (WEBDISK_CARD), Y
: lda (WEBDISK_CARD), Y
  bne :-
  iny
  lda (WEBDISK_CARD), Y
  bne :+
  ldy #$4
  lda (WEBDISK_CARD), Y
  sta StartPRG+1
  iny
  lda (WEBDISK_CARD), Y
  sta StartPRG+2
  jsr StartPRG
: rts
.endproc

.proc _WD_LoadTextFile: near
  jsr SetCardData
  lda #$d6
  jmp CardOp
.endproc

.proc _WD_LoadMarkdown: near
  jsr SetCardData
  lda #$d7
  jmp CardOp
.endproc
