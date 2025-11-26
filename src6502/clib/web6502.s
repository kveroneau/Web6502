.import popax
.export _IdleLoop, _SetRealTime, _SetTimer

.importzp ptr2

.proc SetUp: near
  clc
  adc #$c0
  sta ptr2+1
  lda #$02
  sta ptr2
  jsr popax
  ldy #$0
  sta (ptr2),Y
  iny
  txa
  sta (ptr2),Y
  lda #$00
  sta ptr2
  dey
  rts
.endproc

.proc _WriteTo: near
  jsr SetUp
  lda #$80
  sta (ptr2),Y
  rts
.endproc

.proc _SetTo: near
  jsr SetUp
  lda #$82
  sta (ptr2),Y
  lda #$80
  sta (ptr2),Y
  rts
.endproc

.proc _IdleLoop: near
  cli
: lda #$40
  sta $fff0
  lda #$41
  sta $fff0
  jmp :-
.endproc

.proc _SetRealTime: near
  lda #$41
  sta $fff0
  rts
.endproc

.proc _SetTimer: near
  lda #$40
  sta $fff0
  rts
.endproc
