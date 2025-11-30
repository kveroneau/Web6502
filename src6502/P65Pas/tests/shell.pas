////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program shell;

uses Web6502, crt6502, disk6502;
{$ORG $0801}
{$SET_DATA_ADDR '5000-5FFF'}

var
  DISK_TYPE: byte;
  disk4: string = 'disk4';
  disk6: string = 'disk6';
  disk7: string = 'disk7';
  prmpt: array[10] of char;
  prmptc: string = ':> ';
  cmd: array[60] of char;

procedure SetDisk(cardid: byte; dstr: pointer);
begin
  if cardio[cardid] = 0 then
    WriteLn(@'?SLOT EMPTY');
    Exit;
  end;
  DISK_TYPE:=cardio[cardid];
  SetDiskCard(cardid);
  strcpy(@prmpt, dstr);
  strcat(@prmpt, @prmptc);
end; 

procedure StartAddress(addr: pointer);
begin
  asm
    LDA addr
    STA startprg+1
    LDA addr+1
    STA startprg+2
startprg:
    JSR $ffff
  end;
end;

procedure RunCommand(prg: pointer): boolean;
var
  addr: pointer absolute $26;
  ftype: byte;
begin
  SetRealTime(False);
  if DISK_TYPE = $d6 then
    strcat(prg, @'.prg');
    addr:=LoadPRG(prg);
  else
    ftype:=GetFileType(prg);
    if ftype = 0 then
      LoadTextFile(prg);
      Exit(True);
    elsif ftype = 3 then
      addr:=LoadPRG(prg);
    else
      Exit(False);
    end; 
  end;
  if addr = Word(0) then
    Exit(False);
  end;
  StartAddress(addr);
  Exit(True);
end;

procedure Shell;
var
  running: boolean;
begin
  SetDisk(6, @disk6);
  running:=True;
  repeat 
	   SetRealTime(False);
     Prompt(@prmpt, @cmd);
     SetRealTime(True);
     if strcmp(@cmd, @'exit') then
       running:=False;
     elsif strcmp(@cmd, @'cls') then
       ClrScr;
     elsif strcmp(@cmd, @disk4) then
       SetDisk(4, @disk4);
     elsif strcmp(@cmd, @disk6) then
       SetDisk(6, @disk6);
     elsif strcmp(@cmd, @disk7) then
       SetDisk(7, @disk7);
     else
       if RunCommand(@cmd) = False then
         WriteLn(@'Program not found.');
       end;
     end; 
  until running = False;
end; 

begin
  WriteLn(@'Web6502 Shell v0.1');
  WriteLn(@'PRG Version written in P65Pas.');
  if cardio[0] = $76 then
    Shell;
  else
    WriteLn(@'Unfortunately, this shell can only run on a VT100 compatible output card.');
  end;
  Exit;
end.
