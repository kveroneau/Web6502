////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program tbltest;

uses Web6502, crt6502, table6502;
{$ORG $7000}
{$SET_DATA_ADDR '6000-6FFF'}

var
  DBPrompt: string = 'DBShell% ';

procedure DetectTableCard: boolean;
var
  tblcard: byte;
begin
  tblcard:=FindCard($da);
  if tblcard = 0 then
    Exit(False);
  end;
  Write(@'Data Table Card found on Slot #');
  WriteHexByte(tblcard);
  Write(@CRLF);
  InitTableCard(tblcard);
  Exit(True);
end;

procedure ShowCard;
var
  buf: array[40] of char;
begin
  Write(@'Card Type: ');
  LoadStringField(@'cardtype', @buf);
  WriteLn(@buf);
  Write(@'Card Name: ');
  LoadStringField(@'cardname', @buf);
  WriteLn(@buf);
end; 

procedure CardsTest;
var
  i: byte;
begin
  if OpenTable(@'cards') = False then
    WriteLn(@'Unable to open database.');
    Exit;
  end;
  SeekFirst;
  for i:=0 to TBL_RECS^-1 do
    ShowCard;
    SeekNext;
  end;
  CloseTable;
end; 

procedure DBShell;
var
  running: boolean;
  cmd: array[40] of char;
  prmpt: array[20] of char;
begin
  strcpy(@prmpt, @DBPrompt);
  running:=True;
  repeat 
	   SetRealTime(False);
     Prompt(@prmpt, @cmd);
     if strcmp(@cmd, @'exit') then
       CloseTable;
       running:=False;
     elsif strcmp(@cmd, @'use') then
       Prompt(@'Database: ', @cmd);
       if OpenTable(@cmd) then
         WriteLn(@'Table found and opened.');
         Write(@'Record count: ');
         WriteHexByte(TBL_RECS^);
         Write(@CRLF);
         strcpy(@prmpt, @cmd);
         strcat(@prmpt, @'% ');
       else
         WriteLn(@'Could not open table.');
       end;
     elsif strcmp(@cmd, @'close') then
       CloseTable;
       Prompt(@cmd, @DBPrompt);
     elsif strcmp(@cmd, @'cards') then
       CardsTest;
     else
       WriteLn(@'Command not found.');
     end; 
  until running = False;
end; 

begin
  WriteLn(@'Data Table Card Test Program started.');
  if DetectTableCard = false then
    WriteLn(@'No Data Table Card detected, exiting....');
    Exit;
  end;
  DBShell;
  Exit;
end.

