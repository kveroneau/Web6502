unit canvas6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, Web;

type

  { T6502CanvasCard }

  T6502CanvasCard = class(T6502Card)
  private
    FCanvas: TJSCanvasRenderingContext2D;
    FRow, FCol: byte;
    function OnKeyPress(AEvent: TJSKeyboardEvent): Boolean;
    procedure SetCanvas(AValue: string);
    procedure Write;
  protected
    function GetCardType: byte; override;
  public
    property CanvasID: string write SetCanvas;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502CanvasCard }

function T6502CanvasCard.OnKeyPress(AEvent: TJSKeyboardEvent): Boolean;
begin
  Memory[1]:=Ord(AEvent.Key[1]);
end;

procedure T6502CanvasCard.SetCanvas(AValue: string);
var
  el: TJSHTMLCanvasElement;
begin
  el:=TJSHTMLCanvasElement(document.getElementById(AValue));
  document.onkeypress:=@OnKeyPress;
  FCanvas:=el.getContextAs2DContext('2d');
end;

procedure T6502CanvasCard.Write;
begin
  FCanvas.strokeText(SysMemory.GetStringPtr($c002), FCol*10,FRow*10);
  Inc(FRow);
end;

function T6502CanvasCard.GetCardType: byte;
begin
  Result:=$2d;
end;

constructor T6502CanvasCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas:=Nil;
  FRow:=1;
  FCol:=1;
end;

procedure T6502CanvasCard.CardRun;
var
  op: byte;
begin
  if FCanvas = Nil then
    Exit;
  op:=Memory[0];
  if op > 0 then
  begin
    case op of
      $80: Write;
    end;
    Memory[0]:=0;
  end;
end;

end.

