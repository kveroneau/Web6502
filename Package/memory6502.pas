unit Memory6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, rom6502;

type

  { T6502Memory }

  T6502Memory = class(TComponent)
  private
    FActive: Boolean;
    FROMs: Array[0..3] of T6502ROM;
    function GetMemory(addr: word): byte;
    function GetROM(i: byte): T6502ROM;
    procedure SetActive(AValue: Boolean);
    procedure SetMemory(addr: word; AValue: byte);
    procedure LoadInROMs;
    procedure SetROM(i: byte; AValue: T6502ROM);
  public
    property Active: Boolean read FActive write SetActive;
    property Memory[addr: word]: byte read GetMemory write SetMemory;
    property ROM[i: byte]: T6502ROM read GetROM write SetROM;
    procedure SetWord(addr, data: word);
    function GetWord(addr: word): word;
    function GetString(addr: word): string;
    function GetStringPtr(addr: word): string;
    procedure LoadInto(strm: TStream; addr: word);
    procedure LoadString(data: string; addr: word);
    function LoadPRG(strm: TStream): word;
    procedure SaveInto(strm: TStream; addr, size: word);
    function SaveString(addr, size: word): string;
  end;

implementation

procedure jsClearMemory; external name 'window.cpu6502.clearMemory';
procedure jsSetFillByte(b: byte); external name 'window.cpu6502.setFillByte';
procedure jsWriteMemory(addr: word; data: TBytes; isROM: boolean); external name 'window.cpu6502.writeMemory';
function jsReadMemory(addr, size: word; ignoreROM: boolean): TBytes; external name 'window.cpu6502.readMemory';
procedure jsWriteByteAt(addr: word; data: byte; isROM: boolean); external name 'window.cpu6502.writeByteAt';
function jsReadByteAt(addr: word; ignoreROM: boolean): byte; external name 'window.cpu6502.readByteAt';

{ T6502Memory }

procedure T6502Memory.SetActive(AValue: Boolean);
begin
  if FActive=AValue then Exit;
  if AValue then
  begin
    jsSetFillByte($00);
    jsClearMemory;
    LoadInROMs;
  end;
  FActive:=AValue;
end;

function T6502Memory.GetMemory(addr: word): byte;
begin
  Result:=jsReadByteAt(addr, False);
end;

function T6502Memory.GetROM(i: byte): T6502ROM;
begin
  Result:=FROMs[i];
end;

procedure T6502Memory.SetMemory(addr: word; AValue: byte);
begin
  jsWriteByteAt(addr, AValue, False);
end;

procedure T6502Memory.LoadInROMs;
var
  i: Integer;
begin
  for i:=0 to 3 do
    if Assigned(FROMs[i]) and FROMs[i].Active then
      LoadInto(FROMs[i].ROMStream, FROMs[i].Address);
end;

procedure T6502Memory.SetROM(i: byte; AValue: T6502ROM);
begin
  FROMs[i]:=AValue;
end;

procedure T6502Memory.SetWord(addr, data: word);
begin
  jsWriteByteAt(addr, data and $ff, False);
  jsWriteByteAt(addr+1, data shr 8, False);
end;

function T6502Memory.GetWord(addr: word): word;
begin
  Result:=(jsReadByteAt(addr+1, False) shl 8)+jsReadByteAt(addr, False);
end;

function T6502Memory.GetString(addr: word): string;
var
  b: byte;
begin
  Result:='';
  repeat
    b:=jsReadByteAt(addr, False);
    if b <> 0 then
      Result:=Result+chr(b);
    Inc(addr);
  until b = 0;
end;

function T6502Memory.GetStringPtr(addr: word): string;
begin
  Result:=GetString(GetWord(addr));
end;

procedure T6502Memory.LoadInto(strm: TStream; addr: word);
var
  buf: TBytes;
begin
  strm.Read(buf, strm.Size-strm.Position);
  jsWriteMemory(addr, buf, False);
end;

procedure T6502Memory.LoadString(data: string; addr: word);
var
  i: Integer;
begin
  for i:=0 to Length(data)-1 do
    jsWriteByteAt(addr+i, ord(data[i+1]), False);
end;

function T6502Memory.LoadPRG(strm: TStream): word;
var
  addr: word;
begin
  addr:=strm.ReadByte+(strm.ReadByte shl 8);
  LoadInto(strm, addr);
  Result:=addr;
end;

procedure T6502Memory.SaveInto(strm: TStream; addr, size: word);
var
  buf: TBytes;
begin
  buf:=jsReadMemory(addr, size, True);
  strm.Write(buf, size);
end;

function T6502Memory.SaveString(addr, size: word): string;
var
  data: string;
  i: Integer;
begin
  SetLength(data, size);
  for i:=0 to size-1 do
    data[i+1]:=chr(jsReadByteAt(addr+i, True));
  Result:=data;
end;

end.

