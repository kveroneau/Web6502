unit DeviceHub6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dev6502, Memory6502;

type

  { T6502DeviceHub }

  T6502DeviceHub = class(T6502Device)
  private
    FDevices: Array[0..7] of T6502Device;
    function GetDevice(i: integer): T6502Device;
    procedure SetDevice(i: integer; AValue: T6502Device);
  protected
    procedure SetMemory(AValue: T6502Memory); override;
    function GetDeviceType: byte; override;
  public
    property Device[i: integer]: T6502Device read GetDevice write SetDevice;
    procedure DeviceRun; override;
    function FindType(devtype: byte): T6502Device;
  end;

implementation

{ T6502DeviceHub }

function T6502DeviceHub.GetDevice(i: integer): T6502Device;
begin
  Result:=FDevices[i];
end;

procedure T6502DeviceHub.SetDevice(i: integer; AValue: T6502Device);
begin
  FDevices[i]:=AValue;
end;

procedure T6502DeviceHub.SetMemory(AValue: T6502Memory);
var
  i: Integer;
begin
  inherited SetMemory(AValue);
  if AValue = Nil then
  begin
    for i:=0 to 7 do
      if Assigned(FDevices[i]) then
        FDevices[i].Memory:=Nil;
  end
  else
  begin
    for i:=0 to 7 do
      if Assigned(FDevices[i]) then
        FDevices[i].Memory:=AValue;
  end;
end;

function T6502DeviceHub.GetDeviceType: byte;
begin
  Result:=$80;
end;

procedure T6502DeviceHub.DeviceRun;
var
  i: Integer;
begin
  for i:=0 to 7 do
    if Assigned(FDevices[i]) then
      FDevices[i].DeviceRun;
end;

function T6502DeviceHub.FindType(devtype: byte): T6502Device;
var
  i: Integer;
begin
  Result:=Nil;
  for i:=0 to 7 do
    if Assigned(FDevices[i]) and (FDevices[i].DeviceType = devtype) then
    begin
      Result:=FDevices[i];
      Exit;
    end;
end;

end.

