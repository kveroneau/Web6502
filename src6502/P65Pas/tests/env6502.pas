////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit env6502;

interface

uses Web6502;

var
  ENV_IDX: ^byte;

procedure InitEnvCard(cardid: byte; ekey, evalue: pointer);
procedure EnvByIndex(idx: byte registerA);
procedure EnvByName(s, dest: pointer): boolean;

implementation

var
  ENV_CARD: ^byte absolute $2a;

procedure InitEnvCard(cardid: byte; ekey, evalue: pointer);
begin
  if cardio[cardid] <> $1e then
    Exit;
  end;
  ENV_CARD:=Word(0);
  ENV_IDX:=Word(1);
  asm 
	  CLC
    LDA cardid
    ADC #$c0
    STA ENV_CARD+1
    STA ENV_IDX+1
    LDY #2
    LDA ekey
    STA (ENV_CARD), Y
    INY
    LDA ekey+1
    STA (ENV_CARD), Y
    INY
    LDA evalue
    STA (ENV_CARD), Y
    INY
    LDA evalue+1
    STA (ENV_CARD), Y
  end;
end;

procedure EnvByIndex(idx: byte registerA);
begin
  ENV_IDX^:=idx;
  ENV_CARD^:=$e4;
end; 

{ Currently this will override the ekey, evalue provided to InitEnvCard,
  I am still trying to decide how to make this work, while also ensuring it
  runs optimally for operations like EnvByIndex.  Perhaps making it work like
  CFFA1's OpenDir and ReadDir, but OpenEnv, and ReadEnv... }
procedure EnvByName(s, dest: pointer): boolean;
begin
  asm 
	  LDY #2
    LDA s
    STA (ENV_CARD), Y
    INY
    LDA s+1
    STA (ENV_CARD), Y
    INY
    LDA dest
    STA (ENV_CARD), Y
    INY
    LDA dest+1
    STA (ENV_CARD), Y
  end;
  ENV_CARD^:=$e1;
  asm
	  LDY #1
    LDA (ENV_CARD), Y
    BEQ done1
    LDA #0
    RTS
done1:
    LDA #$ff
  end; 
end;

end.
