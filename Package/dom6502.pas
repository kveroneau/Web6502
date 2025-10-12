unit dom6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, Web;

type

  { T6502DOMOutput }

  T6502DOMOutput = class(T6502Card)
  private
    FBuffer: TStringList;
    FElement: TJSHTMLElement;
    procedure SetElement(AValue: string);
  protected
    function GetCardType: byte; override;
  public
    property Target: string write SetElement;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502DOMOutput }

procedure T6502DOMOutput.SetElement(AValue: string);
begin
  FElement:=TJSHTMLElement(document.getElementById(AValue));
end;

function T6502DOMOutput.GetCardType: byte;
begin
  Result:=$80;
end;

constructor T6502DOMOutput.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FElement:=Nil;
  FBuffer:=TStringList.Create;
end;

procedure T6502DOMOutput.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op > 0 then
  begin
    case op of
      $80: FBuffer.Add(SysMemory.GetStringPtr($c002));
    end;
    FElement.innerHTML:=FBuffer.Text;
    Memory[0]:=0;
  end;
end;

end.

