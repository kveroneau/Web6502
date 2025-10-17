unit Status6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dev6502, Web;

type

  { T6502StatusDevice }

  T6502StatusDevice = class(T6502Device)
  private
    FElement: TJSHTMLElement;
  protected
    function GetDeviceType: byte; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DeviceRun; override;
  end;

implementation

function jsGetPC: word; external name 'window.cpu6502.getPC';

{ T6502StatusDevice }

function T6502StatusDevice.GetDeviceType: byte;
begin
  Result:=$00 { Hidden from 6502 System and Code. }
end;

constructor T6502StatusDevice.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FElement:=TJSHTMLElement(document.getElementById('status6502'));
end;

procedure T6502StatusDevice.DeviceRun;
begin
  FElement.innerHTML:='<b>PC:</b> $'+IntToHex(jsGetPC, 4);
end;

end.

