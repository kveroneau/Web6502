////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
program envtest;

uses Web6502, crt6502, env6502;
{$ORG $7000}
{$SET_DATA_ADDR '6000-6FFF'}

var
  env_key: array[40] of char;
  env_value: array[60] of char;

procedure DetectEnvCard: boolean;
var
  envcard: byte;
begin
  envcard:=FindCard($1e);
  if envcard = 0 then
    Exit(False);
  end;
  Write(@'Environment Card found on Slot #');
  WriteHexByte(envcard);
  Write(@CRLF);
  InitEnvCard(envcard, @env_key, @env_value);
  Exit(True);
end;

procedure ListEnv;
var
  i: byte;
begin
  i:=0;
  repeat 
	   EnvByIndex(i);
     if ENV_IDX^ <> $ff then
       Write(@env_key);
       Write(@' = ');
       WriteLn(@env_value);       
     end;
     Inc(i);
  until ENV_IDX^ = $ff;
end; 

procedure EnvShell;
var
  running: boolean;
  cmd: array[40] of char;
begin
  running:=True;
  repeat
    SetRealTime(False);
    Prompt(@'Env$ ', @cmd);
    SetRealTime(True);
    if strcmp(@cmd, @'exit') then
      running:=False;
    elsif strcmp(@cmd, @'list') then
      ListEnv;
    elsif strcmp(@cmd, @'get') then
      if EnvByName(@'hello', @env_value) then
        Write(@'It exists: ');
        WriteLn(@env_value);
      else
        WriteLn(@'Env "hello" did not exist.');
      end; 
    else
      WriteLn(@'Try instead: exit, list, get');
    end; 
  until running = False;
end; 

begin
  WriteLn(@'Environment Card Test Program started.');
  if DetectEnvCard = false then
    WriteLn(@'No Environment Card detected, exiting....');
    Exit;
  end;
  EnvShell;
  Exit;
end.
