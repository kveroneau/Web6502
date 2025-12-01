////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program mousetest;

uses Web6502, crt6502;
{$ORG $2000}

var
  running: boolean;
  X_ROW: byte = 1;
  X_COL: byte = 5;
  
begin
  ClrScr;
  GotoXY(1,30);
  Write(@'Mouse Testing Program.');
  SetMouse(True);
  GotoXY(5,1);
  Write(@'Please press a mouse button...');
  GotoXY(X_ROW, X_COL);
  Write(@'[X]');
  running:=True;
  repeat
    MOUSE_BTN:=0;
    SetRealTime(False);
    repeat
	 
    until MOUSE_BTN <> 0;
    SetRealTime(True);
    GotoXY(8,1);
    Write(@'Mouse X: ');
    WriteHexByte(MOUSE_ROW);
    GotoXY(9,1);
    Write(@'Mouse Y: ');
    WriteHexByte(MOUSE_COL);
    if MOUSE_ROW = X_ROW then
      if MOUSE_COL >= X_COL then
        if MOUSE_COL <= X_COL+2 then
          running:=False;
        end; 
      end; 
    end; 
  until running = False;
  SetMouse(False);
  ClrScr;
  asm 
	  LDA #$42
    STA $fff0
  end;
end.
