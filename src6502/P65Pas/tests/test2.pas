////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
program test2;

uses Web6502, crt6502, cffa1;
{$ORG $7000}

procedure ListDir;
var
  fname: pointer;
begin
  OpenDir;
  repeat 
    fname:=ReadDir;
    if strcmp(fname, @'null') then
      Exit;
    end; 
    Write(@'  ');
    WriteLn(fname);
  until FALSE;
end; 

procedure CFFA1Shell;
var
  running, rt: boolean;
  cmd: array[40] of char;
  sz: word;
begin
  rt:=False;
  running:=True;
  WriteLn(@'CFFA1 Shell v0.2 READY.');
  repeat 
    SetRealTime(False);
    Prompt(@'CFFA1> ', @cmd);
    SetRealTime(rt);
    if strcmp(@cmd, @'exit') then
      running:=False;
    elsif strcmp(@cmd, @'dir') then
      ListDir;
    elsif strcmp(@cmd, @'rt') then
      rt:=True;
    elsif strcmp(@cmd, @'save') then
      SetRealTime(False);
      Prompt(@'String to save: ', @cmd);
      SetRealTime(rt);
      SaveFile(@'test2.bin', @cmd, Word(40));
    elsif strcmp(@cmd, @'load') then
      sz:=LoadFile(@'test2.bin', @cmd);
      WriteHexWord(sz);
      WriteLn(@' bytes read.');
      Write(@'Data Saved: ');
      WriteLn(@cmd);
    else
      WriteLn(@'?SYNTAX ERROR');
    end; 
  until running = False;
end; 

procedure DetectCFFA1;
var
  cffa: byte;
begin
  cffa:=FindCard($cf);
  if cffa = 0 then
    Exit;
  end;
  Write(@'Detected CFFA1 Card on Slot #');
  WriteHexByte(cffa);
  Write(@', Initializing Card...');
  InitCFFA1(cffa);
  WriteLn(@'done.');
  CFFA1Shell;
end; 

begin
  DetectCFFA1;
  Exit;
end.

