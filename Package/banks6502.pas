unit banks6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dev6502;

type

  { T6502BankedMemory }

  T6502BankedMemory = class(T6502Device)
  private
    FBankPage: word;
    FBanks: byte;
    FCurBank: byte;
    FPages: byte;
    FBank: Array of TBytes;
    procedure SetBankPage(AValue: word);
    procedure SetBanks(AValue: byte);
  protected
    function GetDeviceType: byte; override;
  public
    property Banks: byte read FBanks write SetBanks;
    property BankPage: word read FBankPage write SetBankPage;
    property Pages: byte read FPages write FPages;
    constructor Create(AOwner: TComponent); override;
    procedure DeviceRun; override;
  end;

implementation

procedure jsWriteMemory(addr: word; data: TBytes; isROM: boolean); external name 'window.cpu6502.writeMemory';
function jsReadMemory(addr, size: word; ignoreROM: boolean): TBytes; external name 'window.cpu6502.readMemory';

{ T6502BankedMemory }

procedure T6502BankedMemory.SetBanks(AValue: byte);
begin
  if FBanks=AValue then Exit;
  SetLength(FBank, AValue+1);
  FBanks:=AValue+1;
end;

procedure T6502BankedMemory.SetBankPage(AValue: word);
begin
  FBankPage:=AValue and $ff00;
end;

function T6502BankedMemory.GetDeviceType: byte;
begin
  Result:=$d1;
end;

constructor T6502BankedMemory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Ctrl:=$ffd1;
  FCurBank:=0;
  FBanks:=0;
end;

procedure T6502BankedMemory.DeviceRun;
var
  op: byte;
begin
  op:=FMemory.Memory[Ctrl];
  if op > FBanks then
    op:=0;
  if op = FCurBank then
    Exit;
  FBank[FCurBank]:=jsReadMemory(FBankPage, FPages shl 8, True);
  jsWriteMemory(FBankPage, FBank[op], False);
  FCurBank:=op;
end;

end.

