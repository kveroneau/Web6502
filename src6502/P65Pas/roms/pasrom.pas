////////////////////////////////////////////
// New program created in 28-11-25}
////////////////////////////////////////////
program pasrom;

{$BOOTLOADER $53,$01}
uses rom6502;

procedure ExecPRG(fname: pointer absolute $c602);
var
  DISK_API: byte absolute $c600;
  DISK_ERR: byte absolute $c601;
begin
  DISK_API:=$d4;
  repeat 
	  
  until DISK_API = 0;
  if DISK_ERR = 0 then
    Write(@', Loading PRG...');
    asm 
	    JMP ($c604) 
    end; 
  end; 
end;

begin
  Write(@'; PasROM v0.1');
  ExecPRG(@'test.prg');
  Exit;
end.

