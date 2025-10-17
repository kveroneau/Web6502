.import popax
.export _InitBlog, _BlogTitle, _BlogPath, _BlogDate, _SetFilter, _SetBlogContent

.importzp ptr2

.bss

BLOG_CARD: .res 1

_BlogTitle: .res 60
_BlogPath: .res 40
_BlogDate: .res 60

.code

.proc SetCard: near
  clc
  adc #$c0
  sta ptr2+1
  ldy #0
  rts
.endproc

.proc _InitBlog: near
  sta BLOG_CARD
  jsr SetCard
  lda #$20
  sta ptr2
  lda #<_BlogTitle
  sta (ptr2),Y
  iny
  lda #>_BlogTitle
  sta (ptr2),Y
  iny
  lda #<_BlogPath
  sta (ptr2),Y
  iny
  lda #>_BlogPath
  sta (ptr2),Y
  iny
  lda #<_BlogDate
  sta (ptr2),Y
  iny
  lda #>_BlogDate
  sta (ptr2),Y
  rts
.endproc

.proc _SetFilter: near
  pha
  lda BLOG_CARD
  jsr SetCard
  lda #$04
  sta ptr2
  pla
  sta (ptr2),Y
  iny
  txa
  sta (ptr2),Y
  lda #$02
  sta ptr2
  jsr popax
  ldy #$0
  sta (ptr2),Y
  iny
  txa
  sta (ptr2),Y
  lda #$00
  tay
  sta ptr2
  lda #$21
  sta (ptr2),Y
  rts
.endproc

.proc _SetBlogContent: near
  pha
  txa
  pha
  lda BLOG_CARD
  jsr SetCard
  lda #$02
  sta ptr2
  pla
  tax
  pla
  ldy #$0
  sta (ptr2),Y
  iny
  txa
  sta (ptr2),Y
  dey
  lda #$0
  sta ptr2
  lda #$80
  sta (ptr2),Y
  rts
.endproc
