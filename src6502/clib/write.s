.import popax
.export _write

.importzp ptr2, tmp1, tmp2

.include "kernel.inc"

.proc out_a: near
    sty tmp2
    ldy #5
    jsr OutputAPI
    ldy tmp2
    rts
.endproc

.proc _write: near
    sta tmp1
    jsr popax
    sta ptr2
    stx ptr2+1
    jsr popax
    cmp #1
    beq :+
    rts
:   ldy #0
:   lda (ptr2), Y
    jsr out_a
    iny
    cpy tmp1
    bne :-
    rts
.endproc
