unit vt6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, webvt100;

type

  { TVT100Card }

  TVT100Card = class(T6502Card)
  private
    FTerm: TWebTerminal;
    FCmdBuf: word;
    procedure HandleLine(const data: string);
    procedure SyncMemory;
    procedure DoPrompt;
  published
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ TVT100Card }

procedure TVT100Card.HandleLine(const data: string);
var
  i: Integer;
begin
  for i:=0 to Length(data)-1 do
    SysMemory.Memory[FCmdBuf+i]:=ord(data[i+1]);
  SysMemory.Memory[FCmdBuf+i+2]:=0;
end;

procedure TVT100Card.SyncMemory;
var
  x,y: byte;
begin
  FTerm.Attr:=Memory[$20];
  x:=Memory[$21];
  y:=Memory[$22];
  if (x > 0) and (y > 0) then
  begin
    FTerm.MoveTo(x,y);
    SetWord($21,0);
  end;
end;

procedure TVT100Card.DoPrompt;
begin
  FTerm.Prompt:=GetStringPtr(2);
  FCmdBuf:=GetWord(4);
  FTerm.EnableInput;
end;

function TVT100Card.GetCardType: byte;
begin
  Result:=$76;
end;

constructor TVT100Card.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTerm:=TWebTerminal.Create;
  FTerm.OnPayload:=@HandleLine;
  FTerm.WriteLn('6502 Terminal Card Initialized.');
  FCmdBuf:=$c0a0;
end;

procedure TVT100Card.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  SyncMemory;
  case op of
    $80: FTerm.Write(GetStringPtr(2));
    $81: DoPrompt;
    $82: FTerm.Clear;
  end;
  Memory[0]:=0;
end;

end.

