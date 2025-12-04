////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit crt6502;

interface

uses Web6502;

var
  MOUSE_BTN: byte absolute $c030;
  MOUSE_COL: byte absolute $c031;
  MOUSE_ROW: byte absolute $c032;

procedure Write(s: pointer);
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

procedure SetMask(v: boolean);
procedure SetMouse(v: boolean);

implementation

procedure Write(s: pointer);
begin
  asm 
	  LDA s
    LDX s+1
    LDY #$80
    JMP $d103
  end; 
end; 

procedure WriteLn(s: pointer);
begin
  Write(s);
  asm 
	  LDY #1
    JMP $d103
  end; 
end;

procedure Prompt(s, buf: pointer);
begin
  asm
    LDA buf
    STA $d100
    LDA buf+1
    STA $d101
	  LDA s
    LDX s+1
    LDY #$81
    JMP $d103
  end; 
end; 

procedure ReadChar: char;
begin
  asm 
	  LDY #2
    JMP $d103
  end; 
end; 

procedure SetRAW;
begin
  asm 
	  LDY #$8a
    JMP $d103
  end;
end; 

procedure ClrScr;
begin
  asm 
	  LDY #$82
    JMP $d103
  end; 
end; 

procedure GotoXY(x: byte registerA; y: byte registerX);
begin
  asm 
    LDY #3
    JMP $d103
  end;
end; 

procedure WriteHexByte(b: byte registerA);
begin
  asm
    LDY #$90
	  JMP $d103
  end; 
end; 

procedure WriteHexWord(w: word);
begin
  asm 
	  LDA w
    LDX w+1
    LDY #$91
    JMP $d103
  end; 
end; 

procedure ForegroundColour(fg: byte registerA);
begin
  asm 
	  CLC
    ADC #30
    LDY #4
    JMP $d103
  end; 
end; 

procedure BackgroundColour(bg: byte registerA);
begin
  asm 
	  CLC
    ADC #40
    LDY #4
    JMP $d103
  end; 
end;

procedure SetMask(v: boolean);
begin
  asm 
	  LDA v
    LDY #$8b
    JMP $d103
  end;
end; 

procedure SetMouse(v: boolean);
begin
  asm 
	  LDA v
    LDY #$8c
    JMP $d103
  end;
end;

end.
