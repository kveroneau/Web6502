unit webdisk6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, ajaxlib, Web, CardSlots6502, vt6502;

type

  { T6502WebDisk }

  T6502WebDisk = class(T6502Card)
  private
    FWebFile: TBytesStream;
    FRequest: TWebRequest;
    FRoot: string;
    procedure FileLoaded(Sender: TObject);
    procedure LoadError(Sender: TObject; const AError: string);
    procedure LoadFile;
    procedure WriteTerm(data: string);
    procedure TextFileLoaded;
    procedure LoadTextFile;
  protected
    function GetCardType: byte; override;
  public
    property Root: string read FRoot write FRoot;
    constructor Create(AOwner: TComponent); override;
    procedure CardRun; override;
  end;

implementation

{ T6502WebDisk }

procedure T6502WebDisk.FileLoaded(Sender: TObject);
var
  op: byte;
begin
  op:=Memory[0];
  if op = $d2 then
    SysMemory.LoadInto(FWebFile, GetWord(4))
  else if op = $d4 then
    SetWord(4, SysMemory.LoadPRG(FWebFile));
  Memory[0]:=0;
  FreeAndNil(FWebFile);
  Memory[1]:=$00;
end;

procedure T6502WebDisk.LoadError(Sender: TObject; const AError: string);
begin
  Memory[0]:=0;
  FreeAndNil(FWebFile);
  Memory[1]:=$ff;
end;

procedure T6502WebDisk.LoadFile;
var
  fname: string;
begin
  FWebFile:=TBytesStream.Create;
  fname:=GetStringPtr(2);
  FWebFile.LoadFromURL(FRoot+fname, True, @FileLoaded, @LoadError);
end;

procedure T6502WebDisk.WriteTerm(data: string);
var
  term: TVT100Card;
  i: Integer;
begin
  term:=TVT100Card(T6502CardSlots(Owner).Card[0]);
  for i:=1 to Length(data) do
  begin
    if data[i] = #10 then
      term.Write(#10#13)
    else
      term.write(data[i]);
  end;
end;

procedure T6502WebDisk.TextFileLoaded;
var
  op: byte;
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
  op:=Memory[0];
  if op = $d6 then
    TJSHTMLElement(document.getElementById(GetStringPtr(4))).innerHTML:=FRequest.responseText
  else if op = $d8 then
    WriteTerm(FRequest.responseText);
  FreeAndNil(FRequest);
  Memory[0]:=0;
  Memory[1]:=$00;
end;

procedure T6502WebDisk.LoadTextFile;
var
  fname: string;
begin
  if Assigned(FRequest) then
    Exit;
  fname:=GetStringPtr(2);
  FRequest:=TWebRequest.Create(Nil, 'get', FRoot+fname);
  FRequest.OnChange:=@TextFileLoaded;
  FRequest.DoRequest;
end;

function T6502WebDisk.GetCardType: byte;
begin
  Result:=$d6;
end;

constructor T6502WebDisk.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWebFile:=Nil;
  FRequest:=Nil;
  FRoot:='files/';
end;

procedure T6502WebDisk.CardRun;
var
  op: byte;
begin
  op:=Memory[0];
  if op = 0 then
    Exit;
  if Assigned(FWebFile) then
    Exit;
  case op of
    $d2: LoadFile;
    $d4: LoadFile;
    $d6: LoadTextFile;
    $d8: LoadTextFile;
  else
    Memory[0]:=0;
    Memory[1]:=$ff;
  end;
end;

end.

