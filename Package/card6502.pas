unit Card6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Memory6502;

type

  { T6502Card }

  T6502Card = class(TComponent)
  private
    FMemory: T6502Memory;
    FCardAddr: word;
    FOnInitCard: TNotifyEvent;
    FOnRunCard: TNotifyEvent;
    FSysMemory: T6502Memory;
    function GetMemory(addr: byte): byte;
    procedure SetMemory(addr: byte; AValue: byte);
    procedure SetSysMemory(AValue: T6502Memory);
  protected
    function GetCardType: byte; virtual;
    function GetWord(addr: byte): word;
    function GetString(addr: byte): string;
    function GetStringPtr(addr: byte): string;
  public
    property SysMemory: T6502Memory read FSysMemory write SetSysMemory;
    property CardAddr: word read FCardAddr write FCardAddr;
    property Memory[addr: byte]: byte read GetMemory write SetMemory;
    property CardType: byte read GetCardType;
    property OnRunCard: TNotifyEvent read FOnRunCard write FOnRunCard;
    property OnInitCard: TNotifyEvent read FOnInitCard write FOnInitCard;
    procedure CardRun; virtual;
  end;

implementation

{ T6502Card }

function T6502Card.GetMemory(addr: byte): byte;
begin
  if not Assigned(FMemory) then
    Exit;
  Result:=FMemory.Memory[CardAddr+addr];
end;

procedure T6502Card.SetMemory(addr: byte; AValue: byte);
begin
  FMemory.Memory[CardAddr+addr]:=AValue;
end;

procedure T6502Card.SetSysMemory(AValue: T6502Memory);
begin
  if FSysMemory=AValue then Exit;
  FMemory:=AValue;
  if Assigned(FMemory) and Assigned(FOnInitCard) then
    FOnInitCard(Self);
  FSysMemory:=AValue;
end;

function T6502Card.GetCardType: byte;
begin
  Result:=$99;
end;

function T6502Card.GetWord(addr: byte): word;
begin
  Result:=(Memory[addr+1] shl 8)+Memory[addr];
end;

function T6502Card.GetString(addr: byte): string;
begin
  Result:=SysMemory.GetString(CardAddr+addr);
end;

function T6502Card.GetStringPtr(addr: byte): string;
begin
  Result:=SysMemory.GetStringPtr(CardAddr+addr);
end;

procedure T6502Card.CardRun;
begin
  if Assigned(FOnRunCard) then
    FOnRunCard(Self);
end;

end.

