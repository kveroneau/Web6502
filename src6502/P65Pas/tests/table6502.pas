////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit table6502;

interface

uses Web6502;

var
  TBL_RECS: ^byte;

procedure InitTableCard(cardid: byte);
procedure OpenTable(tbl: pointer): boolean;
procedure CloseTable;

procedure SeekFirst;
procedure SeekLast;
procedure SeekNext;
procedure SeekPrior;

procedure RemoveFilter;
procedure SetFilter(dkey, dvalue: pointer);

procedure LoadStringField(dkey, dest: pointer);
procedure LoadWordField(dkey: pointer): word;
procedure LoadDateTimeField(dkey, dest: pointer);
procedure SetDateFmt(fmt: pointer);

implementation

var
  TBL_CARD: ^byte absolute $2c;
  TBL_ERR: ^byte;

procedure InitTableCard(cardid: byte);
begin
  if cardio[cardid] <> $da then
    Exit;
  end;
  TBL_CARD:=Word(0);
  TBL_ERR:=Word(1);
  TBL_RECS:=Word($10);
  asm 
    CLC
    LDA cardid
    ADC #$c0
    STA TBL_CARD+1
    STA TBL_ERR+1
    STA TBL_RECS+1
  end;
end;

procedure SetParam(param: pointer; p: byte registerY);
begin
  asm 
	  LDA param
    STA (TBL_CARD), Y
    INY
    LDA param+1
    STA (TBL_CARD), Y 
  end; 
end; 

procedure OpenTable(tbl: pointer): boolean;
begin
  SetParam(tbl, 2);
  TBL_CARD^:=$b0;
  TBL_CARD^:=$b1;
  repeat 
	 
  until TBL_ERR^ <> 0;
  if TBL_ERR^ = $7f then
    Exit(True);
  else
    Exit(False);
  end; 
end; 

procedure CloseTable;
begin
  TBL_CARD^:=$ff;
end; 

procedure SeekFirst;
begin
  TBL_CARD^:=$10;
end; 

procedure SeekLast;
begin
  TBL_CARD^:=$11;
end;

procedure SeekNext;
begin
  TBL_CARD^:=$12;
end;

procedure SeekPrior;
begin
  TBL_CARD^:=$13;
end;

procedure RemoveFilter;
begin
  TBL_CARD^:=$20;
end; 

procedure SetFilter(dkey, dvalue: pointer);
begin
  SetParam(dkey, 2);
  SetParam(dvalue, 4);
  TBL_CARD^:=$21;
end; 

procedure LoadStringField(dkey, dest: pointer);
begin
  SetParam(dkey, 2);
  SetParam(dest, 4);
  TBL_CARD^:=$b2;
end;

procedure LoadWordField(dkey: pointer): word;
var
  w: word;
begin
  SetParam(dkey, 2);
  SetParam(w, 4);
  TBL_CARD^:=$b3;
  Exit(w);
end;

procedure LoadDateTimeField(dkey, dest: pointer);
begin
  SetParam(dkey, 2);
  SetParam(dest, 4);
  TBL_CARD^:=$b4;
end;

procedure SetDateFmt(fmt: pointer);
begin
  SetParam(fmt, 2);
  TBL_CARD^:=$bd;
end; 

end.
