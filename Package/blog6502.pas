unit blog6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, jsontable, DB, Web, marked, DateUtils;

type

  { T6502WebsiteBlogCard }

  T6502WebsiteBlogCard = class(T6502Card)
  private
    FTable: TJSONTable;
    procedure BlogLoaded;
    function GetDateInfo: string;
    procedure RecLoaded(DataSet: TDataSet);
    procedure DoLocate;
  protected
    function GetCardType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

const
  DATE_FORMAT = 'dddd mmmm d, yyyy "at" hh:nn';

{ T6502WebsiteBlogCard }

procedure T6502WebsiteBlogCard.BlogLoaded;
begin
  Memory[$10]:=FTable.DataSet.RecordCount;
  FTable.DataSet.AfterScroll:=@RecLoaded;
end;

function T6502WebsiteBlogCard.GetDateInfo: string;
var
  ddiff: TDateTime;
begin
  Result:=FormatDateTime(DATE_FORMAT, FTable.Dates['Created']);
  ddiff:=FTable.Dates['Modified']-FTable.Dates['Created'];
  if ddiff >= 1.0 then
    Result:='<b>Created on</b> '+Result+'<br/><b>Last Updated on</b> '+FormatDateTime(DATE_FORMAT, FTable.Dates['Modified']);
end;

procedure T6502WebsiteBlogCard.RecLoaded(DataSet: TDataSet);
begin
  SysMemory.LoadString(FTable.Strings['Title']+#0, GetWord($20));
  SysMemory.LoadString(FTable.Strings['Path']+#0, GetWord($22));
  SysMemory.LoadString(GetDateInfo+#0, GetWord($24));
end;

procedure T6502WebsiteBlogCard.DoLocate;
begin
  if FTable.DataSet.Locate(GetStringPtr(2), GetStringPtr(4), []) then
    Memory[1]:=$7f
  else
    Memory[1]:=$ff;
end;

function T6502WebsiteBlogCard.GetCardType: byte;
begin
  Result:=$8f;
end;

constructor T6502WebsiteBlogCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTable:=TJSONTable.Create(Self);
  FTable.Datafile:='website';
  FTable.OnSuccess:=@BlogLoaded;
  FTable.Active:=True;
end;

procedure T6502WebsiteBlogCard.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  case op of
    $10: FTable.DataSet.First;
    $11: FTable.DataSet.Last;
    $12: FTable.DataSet.Next;
    $13: FTable.DataSet.Prior;
    $20: FTable.Filter:='';
    $21: FTable.Filter:=GetStringPtr(2)+'='+QuotedStr(GetStringPtr(4));
    $22: DoLocate;
    $80: document.getElementById(GetStringPtr(2)).innerHTML:=markdown(FTable.Strings['Content']);
  end;
  Memory[0]:=0;
end;

end.

