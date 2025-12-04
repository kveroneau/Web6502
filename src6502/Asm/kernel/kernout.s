.import __CARDIO__
.export out_api, out_buf, out_ptr, SetOutputCard, newline, in_char, set_xy, set_attr, out_char

.rodata

crlf:
  .byte $0d, $0a, $0

br:
  .byte "<br/>", $0

.bss

newline:
  .res 2

.code

out_api:
  sta $c000
  rts

out_char:
  sta $c001
  rts

out_buf:
  sta $c002
  stx $c003
  rts

out_ptr:
  sta $c004
  stx $c005
  rts

in_char:
  lda $c004
  rts

set_attr:
  sta $c020
  rts

set_xy:
  sta $c021
  stx $c022
  rts

.proc SetOutputCard: near
  pha
  clc
  adc #$c0
  sta out_api+2
  sta out_char+2
  sta out_buf+2
  sta out_buf+5
  sta out_ptr+2
  sta out_ptr+5
  sta in_char+2
  sta set_xy+2
  sta set_xy+5
  sta set_attr+2
  pla
  tay
  lda __CARDIO__, Y
  cmp #$80
  beq :+
  lda #<crlf
  sta newline
  lda #>crlf
  sta newline+1
  rts
: lda #<br
  sta newline
  lda #>br
  sta newline+1
  rts
.endproc
