////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit dom6502;

interface

uses Web6502;

procedure SetDOMElement(domid: byte absolute $c0e0);

procedure Write(s: pointer);
procedure WriteLn(s: pointer);
procedure ClrScr;

procedure WriteHexByte(b: byte);
procedure WriteHexWord(w: word);

implementation

var
  OUTPUT_CARD: byte absolute $c000;
  OUTPUT_BUF: pointer absolute $c002;

procedure SetDOMElement(domid: byte absolute $c0e0);
begin
  OUTPUT_CARD:=$8e;
end; 
  
procedure Write(s: pointer);
begin
  OUTPUT_BUF:=s;
  OUTPUT_CARD:=$80;
end; 

procedure WriteLn(s: pointer);
begin
  Write(s);
  Write(@'<br/>');
end;

procedure ClrScr;
begin
  OUTPUT_CARD:=$82;
end; 

procedure WriteHexByte(b: byte);
begin
  OUTPUT_BUF:=Word(b);
  OUTPUT_CARD:=$90;
end; 

procedure WriteHexWord(w: word);
begin
  OUTPUT_BUF:=w;
  OUTPUT_CARD:=$91;
end; 

end.
