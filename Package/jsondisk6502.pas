unit jsondisk6502;

{$mode objfpc}{$H+}
{$modeswitch externalclass}

interface

uses
  Classes, SysUtils, Card6502, Web,JS, ajaxlib, marked, CardSlots6502, vt6502;

type

  TJSONFile = Class external name 'Object' (TJSObject)
    fname: string;
    typ: integer; external name 'type';
  end;

  { T6502JSONDisk }

  T6502JSONDisk = class(T6502Card)
  private
    FDiskFile: string;
    FRoot: string;
    FFS: TJSObject;
    FFile: TJSONFile;
    FRequest: TWebRequest;
    FWebFile: TBytesStream;
    procedure DiskLoaded;
    procedure SetDiskFile(AValue: string);
    procedure FileLoaded(Sender: TObject);
    procedure LoadError(Sender: TObject; const AError: string);
    procedure LoadFile;
    procedure TextFileLoaded;
    procedure LoadTextFile;
    procedure LoadJSONFile;
    procedure GetTypeInfo;
    procedure WriteTerm(data: string);
  protected
    function GetCardType: byte; override;
  public
    property DiskFile: string read FDiskFile write SetDiskFile;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502JSONDisk }

procedure T6502JSONDisk.DiskLoaded;
begin
  if not FRequest.Complete then
    Exit;
  if FRequest.Status <> 200 then
  begin
    Memory[1]:=$ff;
    FreeAndNil(FRequest);
    Exit;
  end;
  FFS:=TJSJSON.parseObject(FRequest.responseText);
  Memory[1]:=$00;
  FreeAndNil(FRequest);
end;

procedure T6502JSONDisk.SetDiskFile(AValue: string);
begin
  if FDiskFile=AValue then Exit;
  if Assigned(FRequest) then
    Exit;
  FRequest:=TWebRequest.Create(Self, 'get', FRoot+AValue+'.json');
  FRequest.OnChange:=@DiskLoaded;
  FRequest.DoRequest;
  FDiskFile:=AValue;
end;

procedure T6502JSONDisk.FileLoaded(Sender: TObject);
begin
  case FFile.typ of
    1: SysMemory.LoadInto(FWebFile, GetWord(4));
    3: SetWord(4, SysMemory.LoadPRG(FWebFile));
  end;
  Memory[0]:=0;
  FreeAndNil(FWebFile);
  Memory[1]:=$00;
end;

procedure T6502JSONDisk.LoadError(Sender: TObject; const AError: string);
begin
  Memory[0]:=0;
  FreeAndNil(FWebFile);
  Memory[1]:=$ff;
end;

procedure T6502JSONDisk.LoadFile;
begin
  if Assigned(FWebFile) then
    Exit;
  FWebFile:=TBytesStream.Create;
  FWebFile.LoadFromURL(FRoot+FDiskFile+'/'+FFile.fname, True, @FileLoaded, @LoadError);
end;

procedure T6502JSONDisk.TextFileLoaded;
begin
  if not FRequest.Complete then
    Exit;
  if FRequest.Status <> 200 then
  begin
    FreeAndNil(FRequest);
    Memory[0]:=0;
    Memory[1]:=$ff;
    Exit;
  end;
  case FFile.typ of
    0: WriteTerm(FRequest.responseText);
    4: TJSHTMLElement(document.getElementById(GetStringPtr(4))).innerHTML:=markdown(FRequest.responseText);
  end;
  FreeAndNil(FRequest);
  Memory[0]:=0;
  Memory[1]:=$00;
end;

procedure T6502JSONDisk.LoadTextFile;
begin
  if Assigned(FRequest) then
    Exit;
  FRequest:=TWebRequest.Create(Nil, 'get', FRoot+FDiskFile+'/'+FFile.fname);
  FRequest.OnChange:=@TextFileLoaded;
  FRequest.DoRequest;
end;

procedure T6502JSONDisk.LoadJSONFile;
begin
  GetTypeInfo;
  if Memory[1] <> 0 then
    Exit;
  case FFile.typ of
    0: LoadTextFile;
    1: LoadFile;
    3: LoadFile;
    4: LoadTextFile;
  else
    Memory[0]:=$00;
    Memory[1]:=$7f;
  end;
end;

procedure T6502JSONDisk.GetTypeInfo;
var
  fname: string;
begin
  fname:=GetStringPtr(2);
  if not FFS.hasOwnProperty(fname) then
  begin
    Memory[0]:=$00;
    Memory[1]:=$ff;
    Exit;
  end;
  FFile:=TJSONFile(FFS.Properties[fname]);
  Memory[$a]:=FFile.typ;
  Memory[0]:=0;
  Memory[1]:=0;
end;

procedure T6502JSONDisk.WriteTerm(data: string);
var
  term: TVT100Card;
  i: Integer;
begin
  i:=T6502CardSlots(Owner).Card[0].CardType;
  if i = $76 then
  begin
    term:=TVT100Card(T6502CardSlots(Owner).Card[0]);
    for i:=1 to Length(data) do
    begin
      if data[i] = #10 then
        term.Write(#10#13)
      else
        term.write(data[i]);
    end;
  end
  else if i = $80 then
    TJSHTMLElement(document.getElementById(GetStringPtr(4))).innerHTML:=data;
end;

function T6502JSONDisk.GetCardType: byte;
begin
  Result:=$d7;
end;

constructor T6502JSONDisk.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRequest:=Nil;
  FWebFile:=Nil;
  FFS:=Nil;
  FRoot:='disks/';
end;

procedure T6502JSONDisk.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  if not Assigned(FFS) then
    Exit;
  if Assigned(FRequest) then
    Exit;
  case op of
    $d0: GetTypeInfo;
    $d2: LoadJSONFile;
    $d4: LoadJSONFile;
    $d6: LoadJSONFile;
    $d7: LoadJSONFile;
    $d8: LoadJSONFile;
  else
    Memory[0]:=$00;
    Memory[1]:=$ff;
  end;
end;

end.

