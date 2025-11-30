////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program envrom;

{$BOOTLOADER $c3,$01}
uses rom6502;

var
  ENV_NAME: string = 'prg';
  prgfile: array[40] of char;

var
  ROM_VER: byte absolute $f101;
  // Hardware Cards are statically set in EnvROM.
  OUT: byte absolute $c000;
  OUTB: byte absolute $c002;
  ENV: byte absolute $c200;
  ENVE: byte absolute $c201;
  ENVK: pointer absolute $c202;
  ENVV: pointer absolute $c204;
  DSK: byte absolute $c600;
  DSKE: byte absolute $c601;
  DSKF: pointer absolute $c602;
  DSKA: pointer absolute $c604;

procedure CheckEnv;
begin
  ENVK:=@ENV_NAME;
  ENVV:=@prgfile;
  ENV:=$e1;
  if ENVE <> 0 then
    Exit;
  end;
  Write(@', Loading ');
  Write(@prgfile);
  Write(@'...');
  DSKF:=@prgfile;
  DSK:=$d4;
  repeat 
	 
  until DSK = 0;
  if DSKE <> 0 then
    Write(@'Failed');
    Exit;
  end;
  asm
    JMP ($c604)
  end;
end; 

begin
  Write(@'; EnvROM v');
  OUTB:=ROM_VER;
  OUT:=$90;
  if cardio[2] = $1e then
    CheckEnv;
  end; 
  Exit;
end.
