unit Dev6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Memory6502;

type

  { T6502Device }

  T6502Device = class(TComponent)
  private

  protected
    FMemory: T6502Memory;
    procedure SetMemory(AValue: T6502Memory); virtual;
    function GetDeviceType: byte; virtual; abstract;
  public
    property DeviceType: byte read GetDeviceType;
    property Memory: T6502Memory write SetMemory;
    procedure DeviceRun; virtual; abstract;
  end;

implementation

{ T6502Device }

procedure T6502Device.SetMemory(AValue: T6502Memory);
begin
  FMemory:=AValue;
end;

end.

