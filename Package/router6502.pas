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
    procedure CheckRoute;
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
  SysMemory.LoadString(URL+#0, GetWord($20));
  Memory[1]:=$ff;
  IRQ;
end;

procedure T6502WebRouterCard.InitCard(Sender: TObject);
begin
  SetWord($20, CardAddr+$80);
end;

procedure T6502WebRouterCard.CheckRoute;
var
  route: string;
begin
  route:=Router.RouteFromURL;
  if route = '' then
    Memory[1]:=0
  else
    Memory[1]:=$ff;
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
  case op of
    $40: Router.Push(GetStringPtr(2));
    $41: CheckRoute;
  end;
  Memory[0]:=0;
end;

end.

