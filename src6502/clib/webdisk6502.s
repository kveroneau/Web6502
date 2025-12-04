.import popax
.export _SetWebDisk, _WD_LoadFile, _WD_ExecPRG, _WD_LoadTextFile, _WD_LoadMarkdown

.include "kernel.inc"

.code

.proc _SetWebDisk: near
  ldy #0
  jmp DiskAPI
.endproc

.proc _WD_LoadFile: near
  sta KernelPtr
  stx KernelPtr+1
  jsr popax
  ldy #$d2
  jsr DiskAPI
  bne :+
  lda #$ff
  rts
: lda #0
  rts
.endproc

StartPRG:
  jmp ($c000)

.proc _WD_ExecPRG: near
  ldy #$d4
  jsr DiskAPI
  bne :+
  sta StartPRG+1
  stx StartPRG+2
  jsr StartPRG
: rts
.endproc

.proc _WD_LoadTextFile: near
  sta KernelPtr
  stx KernelPtr+1
  jsr popax
  ldy #$d6
  jmp DiskAPI
.endproc

.proc _WD_LoadMarkdown: near
  sta KernelPtr
  stx KernelPtr+1
  jsr popax
  ldy #$d7
  jmp DiskAPI
.endproc
