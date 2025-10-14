unit terminal6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, libjquery, jsterm;

type

  { T6502TerminalCard }

  T6502TerminalCard = class(T6502Card)
  private
    FTerm: TJQuery;
    FCmdBuf: word;
    FBuffer: string;
    procedure onCommand(command: string; term: TJQuery);
    procedure DoPrompt;
  protected
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502TerminalCard }

procedure T6502TerminalCard.onCommand(command: string; term: TJQuery);
var
  i: Integer;
begin
  FTerm.Enabled:=False;
  for i:=0 to Length(command)-1 do
    SysMemory.Memory[FCmdBuf+i]:=ord(command[i+1]);
  SysMemory.Memory[FCmdBuf+i+2]:=0;
end;

procedure T6502TerminalCard.DoPrompt;
begin
  FTerm.Prompt:=GetStringPtr(2);
  FCmdBuf:=GetWord(4);
  FTerm.Enabled:=True;
end;

function T6502TerminalCard.GetCardType: byte;
begin
  Result:=$42;
end;

constructor T6502TerminalCard.Create(AOwner: TComponent);
var
  params: TJSTerminalOptions;
begin
  inherited Create(AOwner);
  params:=SimpleTerm;
  FTerm:=InitTerminal('terminal', @onCommand, params, Nil);
  FTerm.Enabled:=False;
  FBuffer:='';
  FTerm.Echo('6502 Terminal Card Initialized.');
end;

procedure T6502TerminalCard.CardRun;
var
  op: byte;
begin
  op:=Memory[1];
  if op > 0 then
  begin
    if op = 10 then
    begin
      FTerm.Echo(FBuffer);
      FBuffer:='';
    end
    else
      FBuffer:=FBuffer+chr(op);
    Memory[1]:=0;
  end;
  op:=Memory[0];
  if op = 0 then
    Exit;
  case op of
    $80: FTerm.Echo(GetStringPtr(2));
    $81: DoPrompt;
    $82: FTerm.Clear;
  end;
  Memory[0]:=0;
end;

end.

