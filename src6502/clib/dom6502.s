.import popax
.export _SetDOM, _WriteTo, _SetTo

.proc SetUp: near
  jsr popax
  sta $c002
  stx $c003
  rts
.endproc

.proc _SetDOM: near
  sta $c0e0
  lda #$8e
  sta $c000
  rts
.endproc

.proc _WriteTo: near
  jsr _SetDOM
  jsr SetUp
  lda #$80
  sta $c000
  rts
.endproc

.proc _SetTo: near
  jsr _SetDOM
  jsr SetUp
  lda #$82
  sta $c000
  lda #$80
  sta $c000
  rts
.endproc
