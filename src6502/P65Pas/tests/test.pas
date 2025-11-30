////////////////////////////////////////////
// New program created in 28-11-25}
////////////////////////////////////////////
program test;

uses Web6502, crt6502, disk6502;
{$ORG $0801}
{$SET_DATA_ADDR '5000-5FFF'}

type
  str60 = array[60] of char;

var
  cmd: str60;
  cmd2: str60;
  DEV: pointer absolute $f0;
  pDEV: ^byte absolute $f0;
  pstr: ^str60 absolute $f2;
  pstr2: ^string;
  mystr: string = 'Almost constant string.';
  ftest: byte absolute $9000;

procedure regtest(rs: pointer register);
begin
  WriteLn(rs);
end; 

procedure WriteColour(c: byte registerA);
begin
  asm PHA end;
  Write(@'Colour = ');
  asm PLA end;
  WriteHexByte(c);
  Write(@CRLF);
end; 

procedure ColourTest;
var
  i: byte;
begin
  for i:=0 to 8 do
    ForegroundColour(i);
    WriteColour(i);
  end;
  ForegroundColour(4);
  for i:=0 to 8 do
    BackgroundColour(i);
    WriteColour(i);
  end;
  TextAttr:=0;
end; 

procedure Reload;
begin
  asm
    LDA $f100
    STA doreload+1
doreload:
    JMP $f100
  end;
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
begin
  SetRealTime(False);
  strcat(prg, @'.prg');
  addr:=LoadPRG(prg);
  if addr = Word(0) then
    Exit(False);
  end;
  StartAddress(addr);
  Exit(True);
end; 

procedure PRGTest;
var
  addr: pointer absolute $26;
begin
  addr:=LoadPRG(@'test3.prg');
  Write(@'PRG Load Address = $');
  WriteHexWord(addr);
  Write(@CRLF);
  asm 
	  LDY #0
    LDA (addr), Y
    BNE goprg
    LDA #0
    RTS
goprg: 
  end; 
  WriteLn(@'Running program...');
  StartAddress(addr);
end;

procedure StrTests;
var
  mybuf: str60;
begin
  SetRealTime(False);
  WriteLn(@'Let us have fun with strings!');
  Prompt(@'Give me a string: ', @cmd2);
  SetRealTime(True);
  strcpy(@mybuf, @'Your string was: ');
  strcat(@mybuf, @cmd2);
  WriteLn(@mybuf);
end; 

procedure BasicShell;
var
  running, reboot: boolean;
begin
  running:=TRUE;
  reboot:=FALSE;
  ForegroundColour(0);
  repeat 
	  Prompt(@'> ', @cmd);
    SetRealTime(True);
    if strcmp(@cmd, @'exit') then
      running:=FALSE;
    elsif strcmp(@cmd, @'regtest') then
      regtest(@'Register pass test.');
    elsif strcmp(@cmd, @'memcpy') then
      Write(@'Copying memory...');
      memcpy(@cmd, @cmd2, cmd.length);
      WriteLn(@cmd2);
    elsif strcmp(@cmd, @'addr') then
      Write(@'cmd=$');
      WriteHexWord(@cmd);
      Write(@', Byte=');
      WriteHexByte(byte(cmd[0]));
      Write(@CRLF);
      write(@'cmd2=$');
      WriteHexWord(@cmd2);
      Write(@', Byte=');
      WriteHexByte(byte(cmd2[0]));
      Write(@CRLF);
    elsif strcmp(@cmd, @'pstr') then
      Write(@'pstr=');
      WriteHexWord(@pstr);
      Write(@CRLF);
      WriteLn(@mystr);
    elsif strcmp(@cmd, @'colour') then
      ColourTest;
    elsif strcmp(@cmd, @'cls') then
      ClrScr;
    elsif strcmp(@cmd, @'reload') then
      reboot:=TRUE;
      running:=FALSE;
    elsif strcmp(@cmd, @'disk6') then
      SetDiskCard(6);
    elsif strcmp(@cmd, @'load') then
      SetRealTime(False);
      Write(@'Loading file...');
      if LoadFile(@'ftest.bin', $9000) then
        WriteLn(@'Loaded!');
        Write(@'Checking file...');
        if ftest = $20 then
          WriteLn(@'Looks good!');
        else
          Write(@'Hmm, this is not right: ');
          WriteHexByte(ftest);
          Write(@CRLF);
        end;
      else
        WriteLn(@'Did not Load!');
      end;
    elsif strcmp(@cmd, @'loadprg') then
      SetRealTime(False);
      PRGTest;
    elsif strcmp(@cmd, @'loadtext') then
      SetRealTime(False);
      if LoadTextFile(@'test.txt') = False then
        WriteLn(@'Unable to open file.');
      end;
    elsif strcmp(@cmd, @'strtest') then
      StrTests;
    elsif RunCommand(@cmd) then
      WriteLn(@'Program ended.');
    else
      WriteLn(@'Invalid command.');
    end;
    SetRealTime(False);
  until running = FALSE;
  if reboot then
    Reload;
  end; 
end; 

begin
  ClrScr;
  WriteLn(@'Test Program in PRG loaded successfull!');
  pDEV:=$c600;
  pDEV^:=$80;
  pstr:=@cmd;
  pstr2:=@cmd2;
  BasicShell;
  Exit;
end.

