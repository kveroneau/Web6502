.import __CARD_START__, __CARDIO__
.export disk_api, disk_err, disk_fname, disk_ptr, SetDiskCard, DetectDisks

.bss

disks:
  .res 3

curdisk:
  .res 1

.code

disk_api:
  sta $c600
disk_chk:
  lda $c600
  bne disk_chk
  rts

disk_err:
  lda $c601
  rts

disk_fname:
  sta $c602
  stx $c603
  rts

disk_ptr:
  sta $c604
  stx $c605
  rts

.proc SetDiskCard: near
  cmp #3
  bcs :+
  tay
  lda disks, Y
  beq :+
  sty curdisk
  clc
  adc #$c0
  sta disk_api+2
  sta disk_chk+2
  sta disk_err+2
  sta disk_fname+2
  sta disk_fname+5
  sta disk_ptr+2
  sta disk_ptr+5
: rts
.endproc

return_disks:
  lda curdisk
  pha
  sec
  lda $f4
  sbc #$c0
  sta curdisk
  ldy #0
: lda disks, Y
  cmp curdisk
  beq :+
  iny
  cpy #3
  bne :-
  beq :++
: tya
  jsr SetDiskCard
: pla
  rts

.proc DetectDisks: near
  ldy #0
  sty curdisk
: lda __CARDIO__, Y
  cmp #$d6
  beq :++
  cmp #$d7
  beq :++
: iny
  cpy #8
  bne :--
  jmp return_disks
: tya
  ldy curdisk
  sta disks, Y
  iny
  cpy #3
  beq :+
  sty curdisk
  tay
  bne :--
: jmp return_disks
.endproc
