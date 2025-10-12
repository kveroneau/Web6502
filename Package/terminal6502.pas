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
    procedure onCommand(command: string; term: TJQuery);
  protected
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502TerminalCard }

procedure T6502TerminalCard.onCommand(command: string; term: TJQuery);
begin

end;

function T6502TerminalCard.GetCardType: byte;
begin
  Result:=$76;
end;

constructor T6502TerminalCard.Create(AOwner: TComponent);
var
  params: TJSTerminalOptions;
begin
  inherited Create(AOwner);
  params:=SimpleTerm;
  FTerm:=InitTerminal('terminal', @onCommand, params, Nil);
  FTerm.Enabled:=False;
  FTerm.Echo('6502 Terminal Card Initialized.');
end;

procedure T6502TerminalCard.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  case op of
    $80: FTerm.Echo(GetStringPtr(2));
  end;
  Memory[0]:=0;
end;

end.

