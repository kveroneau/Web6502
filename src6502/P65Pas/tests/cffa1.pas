////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit cffa1;

interface

uses Web6502;

procedure InitCFFA1(cardid: byte);
procedure OpenDir;
procedure ReadDir: pointer;
procedure SaveFile(fname, src: pointer; size: word);
procedure LoadFile(fname, src: pointer): word;

implementation

var
  CFFA1_CARD: ^byte absolute $28;
  CFFA1_DEST: pointer absolute $00;
  CFFA1_NAME: ^byte absolute $02;
  CFFA1_SIZE: word absolute $09;
  CFFA1_RECN: pointer absolute $0b;

procedure InitCFFA1(cardid: byte);
begin
  if cardio[cardid] <> $cf then
    Exit;
  end;
  CFFA1_CARD:=Word(0);
  asm 
	  CLC
    LDA cardid
    ADC #$c0
    STA CFFA1_CARD+1 
  end;
end;

procedure OpenDir;
begin
  CFFA1_CARD^:=$10;
end; 

procedure ReadDir: pointer;
begin
  CFFA1_CARD^:=$12;
  if CFFA1_RECN = Word(0) then
    Exit(Word(0));
  end;
  asm 
	  LDA CFFA1_RECN+1
    STA __H
    LDA CFFA1_RECN
  end; 
end;

procedure SaveFile(fname, src: pointer; size: word);
begin
  CFFA1_DEST:=src;
  CFFA1_SIZE:=size;
  CFFA1_NAME:=fname-1;
  CFFA1_CARD^:=$20;
end; 

procedure LoadFile(fname, src: pointer): word;
begin
  CFFA1_DEST:=src;
  CFFA1_NAME:=fname-1;
  CFFA1_CARD^:=$22;
  Exit(CFFA1_SIZE);
end; 

end.
