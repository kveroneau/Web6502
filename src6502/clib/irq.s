.export initirq, doneirq
.import callirq

.segment "ONCE"

.proc initirq: near
  lda #<doirq
  sta $fffe
  lda #>doirq
  sta $ffff
  rts
.endproc

.code

.proc doneirq: near
  rts
.endproc

.proc doirq: near
  jsr callirq
  rti
.endproc
