unit table6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, jsontable, DateUtils;

type

  { T6502TableCard }

  T6502TableCard = class(T6502Card)
  private
    FTable: TJSONTable;
    FDateFmt, FRoot: string;
    procedure TableLoaded;
    procedure TableFailed;
    procedure DoLocate;
    procedure DoLookup;
  protected
    function GetCardType: byte; override;
  public
    property Root: string read FRoot write FRoot;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502TableCard }

procedure T6502TableCard.TableLoaded;
begin
  Memory[1]:=$7f;
  Memory[$10]:=FTable.DataSet.RecordCount;
end;

procedure T6502TableCard.TableFailed;
begin
  Memory[1]:=$ff;
end;

procedure T6502TableCard.DoLocate;
begin
  if FTable.DataSet.Locate(GetStringPtr(2), GetStringPtr(4), []) then
    Memory[1]:=$7f
  else
    Memory[1]:=$ff;
end;

procedure T6502TableCard.DoLookup;
begin

end;

function T6502TableCard.GetCardType: byte;
begin
  Result:=$da;
end;

constructor T6502TableCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDateFmt:='dddd mmmm d, yyyy "at" hh:nn';
  FTable:=TJSONTable.Create(Self);
  FTable.OnSuccess:=@TableLoaded;
  FTable.OnFailure:=@TableFailed;
  FRoot:='webdb/';
end;

procedure T6502TableCard.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  Memory[1]:=0;
  case op of
    $10: FTable.DataSet.First;
    $11: FTable.DataSet.Last;
    $12: FTable.DataSet.Next;
    $13: FTable.DataSet.Prior;
    $20: FTable.Filter:='';
    $21: FTable.Filter:=GetStringPtr(2)+'='+QuotedStr(GetStringPtr(4));
    $22: DoLocate;
    $b0: FTable.Datafile:=FRoot+GetStringPtr(2);
    $b1: FTable.Active:=True;
    $b2: SysMemory.LoadString(FTable.Strings[GetStringPtr(2)]+#0, GetWord(4));
    $b3: SetWord(4, FTable.Ints[GetStringPtr(2)]);
    $b4: SysMemory.LoadString(FormatDateTime(FDateFmt, FTable.Dates[GetStringPtr(2)])+#0, GetWord(4));
    $bd: FDateFmt:=GetStringPtr(2);
    $ff: FTable.Active:=False;
  end;
  Memory[0]:=0;
end;

end.

