.import popax
.export _write

.importzp ptr2, tmp1

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
    sta $c001
    iny
    cpy tmp1
    bne :-
    rts
.endproc
