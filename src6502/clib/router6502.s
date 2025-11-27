.export _InitRouter, _PushRoute, _CheckRoute, _URL, _RouteSet

.data

_URL: .addr $0000

.zeropage

ROUTE_CARD: .addr $0000

.code

.proc _InitRouter: near
  clc
  adc #$c0
  sta ROUTE_CARD+1
  lda #$20
  sta ROUTE_CARD
  ldy #$0
  lda (ROUTE_CARD),Y
  sta _URL
  iny
  lda (ROUTE_CARD),Y
  sta _URL+1
  lda #$00
  sta ROUTE_CARD
  rts
.endproc

.proc _PushRoute: near
  ldy #$02
  sta (ROUTE_CARD),Y
  iny
  txa
  sta (ROUTE_CARD),Y
  ldy #$0
  lda #$40
  sta (ROUTE_CARD),Y
  rts
.endproc

.proc _CheckRoute: near
  ldy #$0
  lda #$41
  sta (ROUTE_CARD),Y
  iny
  lda (ROUTE_CARD),Y
  ldx #$0
  rts
.endproc

.proc _RouteSet: near
  ldy #$1
  lda (ROUTE_CARD),Y
  beq :+
  pha
  lda #$0
  sta (ROUTE_CARD),Y
  pla
: rts
.endproc
