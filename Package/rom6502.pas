unit rom6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, p2jsres, Web;

type

  { T6502ROM }

  T6502ROM = class(TComponent)
  private
    FActive: Boolean;
    FAddress: word;
    FROMFile: string;
    FROMStream: TBytesStream;
    FOnROMLoad: TNotifyEvent;
    procedure ROMLoaded(Sender: TObject);
    procedure SetActive(AValue: Boolean);
    function GetRST: word;
  public
    property Active: Boolean read FActive write SetActive;
    property Address: word read FAddress write FAddress;
    property ROMFile: string read FROMFile write FROMFile;
    property ROMStream: TBytesStream read FROMStream write FROMStream;
    property OnROMLoad: TNotifyEvent read FOnROMLoad write FOnROMLoad;
    property RST_VEC: word read GetRST;
    destructor Destroy; override;
  end;

implementation

{ T6502ROM }

procedure T6502ROM.ROMLoaded(Sender: TObject);
begin
  FActive:=True;
  if Assigned(FOnROMLoad) then
    FOnROMLoad(Self);
end;

procedure T6502ROM.SetActive(AValue: Boolean);
var
  info: TResourceInfo;
  data: string;
  i: Integer;
begin
  if FActive=AValue then Exit;
  if AValue then
  begin
    FROMStream:=TBytesStream.Create;
    if GetResourceInfo(rsJS, FROMFile, info) then
    begin
      data:=window.atob(info.data);
      for i:=1 to Length(data) do
        FROMStream.WriteByte(ord(data[i]));
      FROMStream.Position:=0;
      ROMLoaded(Self);
    end
    else
      FROMStream.LoadFromURL(FROMFile, True, @ROMLoaded);
  end
  else
  begin
    FreeAndNil(FROMStream);
    FActive:=AValue;
  end;
end;

function T6502ROM.GetRST: word;
var
  hdr: string;
  i: Integer;
begin
  Result:=FAddress;
  hdr:='';
  for i:=5 to 11 do
    hdr:=hdr+chr(FROMStream.Bytes[i]);
  if hdr = 'WebROM$' then
    Result:=FAddress+FROMStream.Bytes[0];
end;

destructor T6502ROM.Destroy;
begin
  if Assigned(FROMStream) then
    FROMStream.Free;
  inherited Destroy;
end;

end.

