unit dom6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, Web;

type

  { T6502DOMOutput }

  T6502DOMOutput = class(T6502Card)
  private
    FBuffer, FElements: TStringList;
    FElement: TJSHTMLElement;
    FLineBuf: string;
    FCurElem: Integer;
    procedure SetElement;
  protected
    function GetCardType: byte; override;
  public
    procedure AddElement(AElement: string);
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502DOMOutput }

procedure T6502DOMOutput.SetElement;
var
  i: Integer;
begin
  i:=Memory[$e0];
  if i > FElements.Count then
    FCurElem:=FElements.Count
  else
    FCurElem:=i;
  FElement:=TJSHTMLElement(document.getElementById(FElements.Strings[FCurElem]));
end;

function T6502DOMOutput.GetCardType: byte;
begin
  Result:=$80;
end;

procedure T6502DOMOutput.AddElement(AElement: string);
var
  i: Integer;
begin
  i:=FElements.Add(AElement);
  if FCurElem = -1 then
  begin
    FCurElem:=i;
    FElement:=TJSHTMLElement(document.getElementById(FElements.Strings[FCurElem]));
  end;
end;

constructor T6502DOMOutput.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FElement:=Nil;
  FBuffer:=TStringList.Create;
  FLineBuf:='';
  FElements:=TStringList.Create;
  FCurElem:=-1;
end;

procedure T6502DOMOutput.CardRun;
var
  op: byte;
begin
  op:=Memory[1];
  if op > 0 then
  begin
    if op = 10 then
    begin
      FBuffer.Add(FLineBuf+'<br/>');
      FLineBuf:='';
      FElement.innerHTML:=FBuffer.Text;
    end
    else
      FLineBuf:=FLineBuf+chr(op);
    Memory[1]:=0;
  end;
  op:=Memory[0];
  if op > 0 then
  begin
    case op of
      $80: FBuffer.Add(GetStringPtr(2));
      $82: FBuffer.Clear;
      $8e: SetElement;
      $90: FBuffer.Add(IntToHex(Memory[2], 2));
      $91: FBuffer.Add(IntToHex(GetWord(2), 4));
      $92: FBuffer.Add(IntToHex(SysMemory.Memory[GetWord(2)], 2));
      $93: FBuffer.Add(IntToHex(SysMemory.GetWord(GetWord(2)), 4));
    end;
    FElement.innerHTML:=FBuffer.Text;
    Memory[0]:=0;
  end;
end;

end.

