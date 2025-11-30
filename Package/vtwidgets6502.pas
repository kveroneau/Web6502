unit vtwidgets6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, vtwidgets;

type

  { TVTScreenCard }

  TVTScreenCard = class(T6502Card)
  private
    FScreen: TVTScreen;
    FWM: TWindowManager;
    FWindow: Array[0..15] of TVTWindow;
    FCurWin: Integer;
    procedure HandleLine(const data: string);
    procedure HandleCtrl(const data: string);
  protected
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
    procedure Write(const data: string);
    procedure WriteLn(const data: string);
    procedure Clear;
  end;

implementation

procedure jsIRQ; external name 'window.cpu6502.irq';

{ TVTScreenCard }

procedure TVTScreenCard.HandleLine(const data: string);
begin
  Memory[4]:=ord(data[1]);
end;

procedure TVTScreenCard.HandleCtrl(const data: string);
begin
  Memory[5]:=ord(data[1]);
  if data = 'C' then
    jsIRQ;
end;

procedure TVTScreenCard.Write(const data: string);
begin
  if FWM = Nil then
    FScreen.WebTerminal.Write(data)
  else
    FWindow[FCurWin].write(data);
end;

procedure TVTScreenCard.WriteLn(const data: string);
begin
  if FWM = Nil then
    FScreen.WebTerminal.WriteLn(data)
  else
    FWindow[FCurWin].writeln(data);
end;

procedure TVTScreenCard.Clear;
begin
  if FWM = Nil then
    FScreen.WebTerminal.Clear;
end;

function TVTScreenCard.GetCardType: byte;
begin
  Result:=$76;
end;

constructor TVTScreenCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScreen:=TVTScreen.Create(Self);
  FScreen.OnInput:=@HandleLine;
  FScreen.OnCtrl:=@HandleCtrl;
  FWM:=Nil;
end;

procedure TVTScreenCard.CardRun;
var
  op: byte;
begin
  op:=Memory[1];
  if op > 0 then
  begin
    if op = 10 then
      Write(#13#10)
    else
      Write(chr(op));
    Memory[1]:=0;
  end;
  if FWM = Nil then
  begin
    op:=Memory[$a];
    if op > 0 then
    begin
      FScreen.WebTerminal.Csi(chr(op));
      Memory[$a]:=0;
    end;
  end;
  op:=Memory[0];
  if op = 0 then
    Exit;
  case op of
    $80: Write(GetStringPtr(2));
{    $81: DoPrompt;}
    $82: Clear;
    $90: Write(IntToHex(Memory[2], 2));
    $91: Write(IntToHex(GetWord(2), 4));
    $92: Write(IntToHex(SysMemory.Memory[GetWord(2)], 2));
    $93: Write(IntToHex(SysMemory.GetWord(GetWord(2)), 4));
  end;
  Memory[0]:=0;
end;

end.

