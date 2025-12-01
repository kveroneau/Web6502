unit storage6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dev6502, Web, Memory6502, puterjs;

type

  { T6502Storage }

  T6502Storage = class(T6502Device)
  private
    FFilename: string;
    FPage, FPages: byte;
    FLoadOnStart: Boolean;
    FWebFile: TBytesStream;
    procedure FileLoaded(Sender: TObject);
    procedure LoadError(Sender: TObject; const AError: string);
    procedure LoadInFile;
    procedure SaveOutFile;
  protected
    function GetDeviceType: byte; override;
    procedure SetMemory(AValue: T6502Memory); override;
  public
    property LoadOnStart: Boolean read FLoadOnStart write FLoadOnStart;
    property Filename: string read FFilename write FFilename;
    property Page: byte read FPage write FPage;
    property Pages: byte read FPages write FPages;
    constructor Create(AOwner: TComponent); override;
    procedure DeviceRun; override;
  end;

implementation

{ T6502Storage }

procedure T6502Storage.FileLoaded(Sender: TObject);
begin
  FMemory.LoadInto(FWebFile, FPage * 256);
  FreeAndNil(FWebFile);
end;

procedure T6502Storage.LoadError(Sender: TObject; const AError: string);
begin
  FreeAndNil(FWebFile);
end;

procedure T6502Storage.LoadInFile;
var
  data, datax: string;
  i, size: Integer;
  b: byte;
begin
  FWebFile:=TBytesStream.Create;
  data:=window.localStorage.getItem(FFilename);
  datax:=data+'x';
  if datax = 'nullx' then
    FWebFile.LoadFromURL(FFilename, True, @FileLoaded, @LoadError)
  else
  begin
    size:=FPages*256;
    for i:=1 to size do
    begin
      b:=ord(data[i]);
      FWebFile.WriteByte(b);
    end;
    FWebFile.Position:=0;
    FileLoaded(Nil);
  end;
end;

procedure T6502Storage.SaveOutFile;
var
  data: string;
  i, size: Integer;
  b: byte;
begin
  if Assigned(FWebFile) then
    Exit;
  data:='';
  FWebFile:=TBytesStream.Create;
  size:=FPages*256;
  FMemory.SaveInto(FWebFile, FPage*256, size);
  FWebFile.Position:=0;
  for i:=0 to size-1 do
  begin
    b:=FWebFile.ReadByte;
    data:=data+chr(b);
  end;
  FreeAndNil(FWebFile);
  window.localStorage.setItem(FFilename, data);
end;

function T6502Storage.GetDeviceType: byte;
begin
  Result:=$d0;
end;

procedure T6502Storage.SetMemory(AValue: T6502Memory);
begin
  inherited SetMemory(AValue);
  if Assigned(AValue) and FLoadOnStart then
    LoadInFile;
end;

constructor T6502Storage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPage:=$d0;
  FPages:=2;
  Ctrl:=$ffd0;
  FLoadOnStart:=False;
end;

procedure T6502Storage.DeviceRun;
var
  op: byte;
begin
  op:=FMemory.Memory[Ctrl];
  if op = $40 then
    LoadInFile
  else if op = $60 then
    SaveOutFile;
  if op > 0 then
    FMemory.Memory[Ctrl]:=0;
end;

end.

