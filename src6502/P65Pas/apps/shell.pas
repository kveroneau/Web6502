////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program shell;

uses Web6502, crt6502, disk6502, banks6502, storage6502;
{$ORG $b000}
{$SET_DATA_ADDR '9000-91FF'}
{$OUTPUTHEX 'SHELL.SYS'}

var
  DISK_TYPE: byte absolute $f5;
  disk0: string = 'disk0';
  disk1: string = 'disk1';
  disk2: string = 'disk2';
  prmpt: array[10] of char;
  prmptc: string = ':> ';
  cmd: array[60] of char;
  DETECTED: string = 'DISK DETECTED.';

procedure SetDisk(diskid: byte; dstr: pointer);
begin
  SetDisk(diskid);
  strcpy(@prmpt, dstr);
  strcat(@prmpt, @prmptc);
end; 

procedure StartAddress(addr: pointer);
begin
  SaveMemory;
  SetBank(1);
  asm
    LDA addr
    STA startprg+1
    LDA addr+1
    STA startprg+2
startprg:
    JSR $ffff
  end;
  SetBank(0);
  LoadMemory;
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
    elsif ftype = 1 then
      addr:=$2000;
      LoadFile(prg, addr);
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
  curdisk: byte absolute $f4;
begin
  if curdisk = 0 then
    strcpy(@prmpt, @disk0);
  elsif curdisk = 1 then
    strcpy(@prmpt, @disk1);
  elsif curdisk = 2 then
    strcpy(@prmpt, @disk2);
  end; 
  strcat(@prmpt, @prmptc);
  running:=True;
  repeat 
	   SetRealTime(False);
     Prompt(@prmpt, @cmd);
     SetRealTime(True);
     if strcmp(@cmd, @'exit') then
       running:=False;
       SetRealTime(False);
     elsif strcmp(@cmd, @'cls') then
       ClrScr;
     elsif strcmp(@cmd, @disk0) then
       SetDisk(0, @disk0);
     elsif strcmp(@cmd, @disk1) then
       SetDisk(1, @disk1);
     elsif strcmp(@cmd, @disk2) then
       SetDisk(2, @disk2);
     elsif strcmp(@cmd, @'halt') then
       asm 
	       LDA #$42
         STA $fff0
       end; 
     else
       if RunCommand(@cmd) = False then
         WriteLn(@'Program not found.');
       end;
     end; 
  until running = False;
end; 

begin
  WriteLn(@'Web6502 Shell v0.2');
  WriteLn(@'SYS Version written in P65Pas.');
  if cardio[0] = $76 then
    Shell;
  else
    WriteLn(@'Unfortunately, this shell can only run on a VT100 compatible output card.');
  end;
  Exit;
end.
