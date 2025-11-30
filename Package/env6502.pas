unit env6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502;

type

  { T6502EnvCard }

  T6502EnvCard = class(T6502Card)
  private
    FVars: TStringList;
    procedure GetEnv;
    procedure GetEnvIdx;
  protected
    function GetCardType: byte; override;
  public
    property Vars: TStringList read FVars;
    procedure CardRun; override;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ T6502EnvCard }

procedure T6502EnvCard.GetEnv;
var
  env: string;
  idx: integer;
begin
  env:=GetStringPtr(2);
  idx:=FVars.IndexOfName(env);
  if idx = -1 then
  begin
    Memory[1]:=$ff;
    Exit;
  end
  else
  begin
    SysMemory.LoadString(FVars.ValueFromIndex[idx]+#0, GetWord(4));
    Memory[1]:=$00;
  end;
end;

procedure T6502EnvCard.GetEnvIdx;
var
  idx: byte;
begin
  idx:=Memory[1];
  if idx > FVars.Count then
  begin
    Memory[1]:=$ff;
    Exit;
  end;
  SysMemory.LoadString(FVars.Names[idx]+#0, GetWord(2));
  SysMemory.LoadString(FVars.ValueFromIndex[idx]+#0, GetWord(4));
end;

function T6502EnvCard.GetCardType: byte;
begin
  Result:=$1e;
end;

procedure T6502EnvCard.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  Writeln('Env API: ',op);
  case op of
    $e1: GetEnv;
    $e2: FVars.Values[GetStringPtr(2)]:=GetStringPtr(4);
    $e3: Memory[1]:=FVars.Count;
    $e4: GetEnvIdx;
  end;
  Memory[0]:=0;
end;

constructor T6502EnvCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVars:=TStringList.Create;
end;

end.

