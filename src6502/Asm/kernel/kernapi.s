.import out_api, out_buf, out_ptr, SetOutputCard, newline, in_char, set_xy, set_attr
.import disk_api, disk_err, disk_fname, disk_ptr, SetDiskCard, disk_addr, file_type

.export OutputAPI, print, println, printbyte, printword
.export DiskAPI

SPTR = $d100

.zeropage

OUTPUT = $f0
OUT_TYP = OUTPUT+2
DISK = OUTPUT+3
DISK_TYP = DISK+2

.code

prompt:
  lda SPTR
  ldx SPTR+1
  sta chk_char+1
  stx chk_char+2
  sta zero_char+1
  stx zero_char+2
  jsr out_ptr
  tya
  jsr out_api
  lda #0
zero_char:
  sta $ffff
chk_char:
  lda $ffff
  beq chk_char
  rts

.proc OutputAPI: near
  cpy #0
  bne :+
  jmp SetOutputCard
: cpy #1
  bne :+
  lda newline
  ldx newline+1
  ldy #$80
  bne :+++
: cpy #2
  bne :++
  lda #0
  jsr out_ptr
: jsr in_char
  beq :-
  rts
: cpy #3
  bne :+
  jmp set_xy
: cpy #4
  bne :+
  jmp set_attr
: jsr out_buf
  cpy #$81
  bne :+
  jmp prompt
: tya
  jmp out_api
.endproc

.proc print: near
  ldy #$80
  jmp OutputAPI
.endproc

.proc println: near
  ldy #$80
  jsr OutputAPI
  ldy #1
  jmp OutputAPI
.endproc

.proc printbyte: near
  ldy #$90
  jmp OutputAPI
.endproc

.proc printword: near
  ldy #$91
  jmp OutputAPI
.endproc

.proc set_disk_ptr: near
  lda SPTR
  ldx SPTR+1
  jmp disk_ptr
.endproc

.proc DiskAPI: near
  cpy #0
  bne :+
  jmp SetDiskCard
: jsr disk_fname
  cpy #$d2
  bne :+
  jsr set_disk_ptr
: tya
  jsr disk_api
  jsr disk_err
  bne :+++
  cpy #$d0
  bne :+
  jmp file_type
: cpy #$d4
  bne :+
  jmp disk_addr
: lda #0
: rts
.endproc
