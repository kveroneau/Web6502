////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit crt6502;

interface

uses Web6502;

procedure Write(s: pointer absolute $c002);
procedure WriteLn(s: pointer register);
procedure Prompt(s, buf: pointer);
procedure ReadChar: char;
procedure SetRAW;
procedure ClrScr;
procedure GotoXY(x,y: byte);
procedure WriteHexByte(b: byte);
procedure WriteHexWord(w: word);
procedure ForegroundColour(fg: byte registerA);
procedure BackgroundColour(bg: byte registerA);

implementation

var
  OUTPUT_CARD: byte absolute $c000;
  OUTPUT_BUF: pointer absolute $c002;
  INPUT_BUF: pointer absolute $c004;
  INPUT_CHAR: byte absolute $c004;
  TEXT_ATTR: byte absolute $c020;

procedure Write(s: pointer);
begin
  OUTPUT_BUF:=s;
  OUTPUT_CARD:=$80;
end; 

procedure WriteLn(s: pointer);
begin
  Write(s);
  Write(@CRLF);
end;

procedure Prompt(s, buf: pointer);
var
  c: ^byte;
begin
  OUTPUT_BUF:=s;
  INPUT_BUF:=buf;
  OUTPUT_CARD:=$81;
  c:=buf;
  c^:=0;
  repeat 

  until c^ <> 0;
end; 

procedure ReadChar: char;
begin
  INPUT_CHAR:=0;
  repeat 

  until INPUT_CHAR <> 0;
end; 

procedure SetRAW;
begin
  OUTPUT_CARD:=$8a;
end; 

procedure ClrScr;
begin
  OUTPUT_CARD:=$82;
end; 

procedure GotoXY(x,y: byte);
var
  rx: byte absolute $c021;
  ry: byte absolute $c022;
begin
  rx:=x;
  ry:=y;
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

procedure ForegroundColour(fg: byte registerA);
begin
  asm 
	  CLC
    ADC #30
    STA TEXT_ATTR 
  end; 
end; 

procedure BackgroundColour(bg: byte registerA);
begin
  asm 
	  CLC
    ADC #40
    STA TEXT_ATTR 
  end; 
end; 

end.
