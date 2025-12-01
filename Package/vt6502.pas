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
    FOnRefresh: TNotifyEvent;
    procedure HandleLine(const data: string);
    procedure HandleCtrl(const data: string);
    procedure HandleMouse(Button, col, row: Integer);
    procedure SyncMemory;
    procedure DoPrompt;
    procedure SetRAWMode;
    procedure SetMask;
    procedure SetMouse;
  published
    function GetCardType: byte; override;
  public
    property OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
    procedure Write(const data: string);
    procedure WriteLn(const data: string);
  end;

implementation

procedure jsIRQ; external name 'window.cpu6502.irq';

{ TVT100Card }

procedure TVT100Card.HandleLine(const data: string);
var
  i: Integer;
begin
  if FTerm.Mode = tmNormal then
  begin
    for i:=1 to Length(data) do
      SysMemory.Memory[FCmdBuf+i-1]:=ord(data[i]);
    SysMemory.Memory[FCmdBuf+i]:=0;
  end
  else
    Memory[4]:=ord(data[1]);
end;

procedure TVT100Card.HandleCtrl(const data: string);
begin
  Memory[5]:=ord(data[1]);
  Memory[6]:=ord(data[2]);
  if data = 'C' then
    jsIRQ
  else if (data = 'F5') and Assigned(FOnRefresh) then
    FOnRefresh(Self);
end;

procedure TVT100Card.HandleMouse(Button, col, row: Integer);
begin
  Memory[$30]:=Button;
  Memory[$31]:=col;
  Memory[$32]:=row;
  jsIRQ;
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
  FTerm.Mode:=tmNormal;
  FTerm.Prompt:=GetStringPtr(2);
  FCmdBuf:=GetWord(4);
  FTerm.EnableInput;
end;

procedure TVT100Card.SetRAWMode;
begin
  FTerm.Mode:=tmRaw;
  FTerm.EnableInput;
end;

procedure TVT100Card.SetMask;
begin
  FTerm.Mode:=tmNormal;
  if Memory[2] = $ff then
    FTerm.Mask:=True
  else
    FTerm.Mask:=False;
end;

procedure TVT100Card.SetMouse;
begin
  if Memory[2] = $ff then
    FTerm.Mouse:=True
  else
    FTerm.Mouse:=False;
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
  FTerm.OnControlCode:=@HandleCtrl;
  FTerm.OnMouse:=@HandleMouse;
  FTerm.WriteLn('6502 Terminal Card Initialized.');
  FCmdBuf:=$c0a0;
  FTerm.Mode:=tmRaw;
end;

procedure TVT100Card.CardRun;
var
  op: byte;
begin
  op:=Memory[1];
  if op > 0 then
  begin
    if op = 10 then
      FTerm.Write(#13#10)
    else
      FTerm.Write(chr(op));
    Memory[1]:=0;
  end;
  op:=Memory[$a];
  if op > 0 then
  begin
    FTerm.Csi(chr(op));
    Memory[$a]:=0;
  end;
  op:=Memory[0];
  if op = 0 then
    Exit;
  SyncMemory;
  case op of
    $80: FTerm.Write(GetStringPtr(2));
    $81: DoPrompt;
    $82: FTerm.Clear;
    $8a: SetRAWMode;
    $8b: SetMask;
    $8c: SetMouse;
    $90: FTerm.Write(IntToHex(Memory[2], 2));
    $91: FTerm.Write(IntToHex(GetWord(2), 4));
    $92: FTerm.Write(IntToHex(SysMemory.Memory[GetWord(2)], 2));
    $93: FTerm.Write(IntToHex(SysMemory.GetWord(GetWord(2)), 4));
  end;
  Memory[0]:=0;
end;

procedure TVT100Card.Write(const data: string);
begin
  FTerm.Write(data);
end;

procedure TVT100Card.WriteLn(const data: string);
begin
  FTerm.WriteLn(data);
end;

end.

