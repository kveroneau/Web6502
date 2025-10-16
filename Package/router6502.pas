unit router6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, webrouter;

type

  { T6502WebRouterCard }

  T6502WebRouterCard = class(T6502Card)
  private
    procedure HandleRoute(URL: String; aRoute: TRoute; Params: TStrings);
    procedure InitCard(Sender: TObject);
  protected
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502WebRouterCard }

procedure T6502WebRouterCard.HandleRoute(URL: String; aRoute: TRoute;
  Params: TStrings);
begin
  SysMemory.LoadString(URL, GetWord($20));
  Memory[1]:=$ff;
  IRQ;
end;

procedure T6502WebRouterCard.InitCard(Sender: TObject);
begin
  SetWord($20, CardAddr+$80);
end;

function T6502WebRouterCard.GetCardType: byte;
begin
  Result:=$43;
end;

constructor T6502WebRouterCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnInitCard:=@InitCard;
  Router.InitHistory(hkHash);
  Router.RegisterRoute('*', @HandleRoute, True);
end;

procedure T6502WebRouterCard.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  { No op codes as of yet. }
end;

end.

