.export _init, _exit
.import _main

.export __STARTUP__ : absolute = 1
.import __HEAP_START__, __HEAP_SIZE__, __DATA_SIZE__, __DATA_LOAD__, __DATA_RUN__

.import zerobss, initlib, donelib, copydata, initirq

.include "zeropage.inc"

.rodata

cwelcome:
    .byte "C Runtime starting...",$00

cdone:
    .byte "done.",$d,$a,$00

.segment "STARTUP"

_init:   lda #<(__HEAP_START__+__HEAP_SIZE__)
         sta sp
         lda #>(__HEAP_START__+__HEAP_SIZE__)
         sta sp+1
         lda #<cwelcome
         sta $c002
         lda #>cwelcome
         sta $c003
         lda #$80
         sta $c000
         jsr zerobss
         jsr copydata
         jsr initlib
         lda #<cdone
         sta $c002
         lda #>cdone
         sta $c003
         lda #$80
         sta $c000
         jsr _main

_exit:   jsr donelib
         rts
         lda #$42
         sta $fff0
         jsr initirq
