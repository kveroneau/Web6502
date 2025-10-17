unit CardSlots6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dev6502, Card6502, Memory6502;

type

  { T6502CardSlots }

  T6502CardSlots = class(T6502Device)
  private
    FCards: Array[0..7] of T6502Card;
    function GetCard(i: Integer): T6502Card;
    procedure SetCard(i: Integer; AValue: T6502Card);
   protected
     procedure SetMemory(AValue: T6502Memory); override;
     function GetDeviceType: byte; override;
   public
     property Card[i: Integer]: T6502Card read GetCard write SetCard;
     procedure DeviceRun; override;
  end;

implementation

const
  CARD_IO = $c000;

{ T6502CardSlots }

function T6502CardSlots.GetCard(i: Integer): T6502Card;
begin
  Result:=FCards[i];
end;

procedure T6502CardSlots.SetCard(i: Integer; AValue: T6502Card);
begin
  FCards[i]:=AValue;
end;

procedure T6502CardSlots.SetMemory(AValue: T6502Memory);
var
  i: Integer;
begin
  inherited SetMemory(AValue);
  if AValue = Nil then
  begin
    for i:=0 to 7 do
      if Assigned(FCards[i]) then
        FCards[i].SysMemory:=Nil;
  end
  else
  begin
    for i:=0 to 7 do
    begin
      if Assigned(FCards[i]) then
      begin
        FCards[i].CardAddr:=CARD_IO+(i*256);
        FCards[i].SysMemory:=FMemory;
        FMemory.Memory[$c800+i]:=FCards[i].CardType;
      end
      else
        FMemory.Memory[$c800+i]:=0;
    end;
  end;
end;

function T6502CardSlots.GetDeviceType: byte;
begin
  Result:=$c0;
end;

procedure T6502CardSlots.DeviceRun;
var
  i: Integer;
begin
  for i:=0 to 7 do
    if Assigned(FCards[i]) then
      FCards[i].CardRun;
end;

end.

