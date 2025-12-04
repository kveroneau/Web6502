////////////////////////////////////////////
// New program created in 11-10-25}
////////////////////////////////////////////
unit Web6502;

{$BOOTLOADER $20,'COD_HL',$a9,$42,$8d,$f0,$ff}
{$STRING NULL_TERMINATED}
{$ORG $5000}
{$SET_DATA_ADDR '00D0-00FF'}

interface

type
  pointer = word;
  string = array[] of char;
  
var
  TextAttr: byte absolute $c020;
  CtrlCode: ^byte;
  IRQ_VEC: pointer absolute $fffe;
  OUTPUT_TYPE: byte;
  cardio: Array[8] of byte absolute $c800;

procedure SetRealTime(v: Boolean);
procedure Idle;

procedure FindCard(cardtyp: byte): byte;

procedure strcmp(s1, s2: pointer): boolean;
procedure strcpy(dest, src: pointer);
procedure strcat(dest, src: pointer);
procedure memcpy(src, dest: pointer; size: byte registerY);

implementation

var
  SYS_API: byte absolute $fff0;

procedure SetRealTime(v: Boolean);
begin
  if v then
    SYS_API:=$41;
  else
    SYS_API:=$40;
  end; 
end; 

procedure Idle;
begin
  asm 
	  lda #$40
    sta $fff0
    lda #$41
    sta $fff0 
  end; 
end; 

procedure strcmp(s1, s2: pointer): boolean;
var
  p1: pointer absolute $20;
  p2: pointer absolute $22;
begin
  p1:=s1;
  p2:=s2;
  asm 
	  LDY #0
loop1:
    LDA (p1), Y
    BEQ eq1
    CMP (p2), Y
    BNE ne1
    INY
    BNE loop1
ne1:
    LDA #$00
    RTS
eq1:
    LDA (p2), Y
    BEQ done1
    BNE ne1
done1:
    LDA #$ff
  end; 
end;

procedure strcpy(dest, src: pointer);
var
  p1: pointer absolute $20;
  p2: pointer absolute $22;
begin
  p1:=src;
  p2:=dest;
  asm 
	  LDY #0
loop2:
    LDA (p1), Y
    STA (p2), Y
    BEQ done2
    INY
    BNE loop2
done2:
  end;
end;

procedure strcat(dest, src: pointer);
var
  p1: pointer absolute $20;
  p2: pointer absolute $22;
begin
  p1:=src;
  p2:=dest;
  asm 
	  LDY #0
loop3:
    LDA (p2), Y
    BEQ null3
    INY
    BNE loop3
null3:
    CLC
    TYA
    ADC p2
    STA p2
    BCC nadd3
    INC p2+1
nadd3:
    LDY #0
cloop3:
    LDA (p1), Y
    STA (p2), Y
    BEQ done3
    INY
    BNE cloop3
done3:
  end; 
end;

procedure memcpy(src, dest: pointer; size: byte registerY);
var
  p1: pointer absolute $20;
  p2: pointer absolute $22;
begin
  p1:=src-1;
  p2:=dest-1;
  asm
loop2:
    LDA (p1), Y
    STA (p2), Y
    DEY
    BNE loop2
  end;
end;

procedure FindCard(cardtyp: byte): byte;
var
  i: byte;
begin
  for i:=0 to 7 do
    if cardio[i] = cardtyp then
      exit(i);
    end; 
  end;
  exit($ff);
end; 

end.

