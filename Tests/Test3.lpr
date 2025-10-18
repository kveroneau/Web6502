program Test3;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, vt6502, storage6502, DeviceHub6502,
  banks6502, cffa6502;

type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FROM: T6502ROM;
    FSlots: T6502CardSlots;
    FTerm: TVT100Card;
    FStorage: T6502Storage;
    FHub: T6502DeviceHub;
    FBanks: T6502BankedMemory;
    FCFFA1: T6502CFFA1Card;
    procedure ROMLoaded(Sender: TObject);
  protected
    procedure DoRun; override;
  public
  end;

procedure TMyApplication.ROMLoaded(Sender: TObject);
begin
  FMemory.Active:=True;
  F6502:=TMOS6502.Create(Self);
  FSlots:=T6502CardSlots.Create(Self);
  FTerm:=TVT100Card.Create(Self);
  FCFFA1:=T6502CFFA1Card.Create(Self);
  FSlots.Card[0]:=FTerm;
  FSlots.Card[1]:=FCFFA1;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.Address;
  FHub.Device[1]:=FSlots;
  FBanks:=T6502BankedMemory.Create(Self);
  FBanks.BankPage:=$a0;
  FBanks.Pages:=$f;
  FHub.Device[2]:=FBanks;
  F6502.Device:=FHub;
  F6502.Active:=True;
  FCFFA1.Compatibility:=True;
  F6502.HaltVector:=$fff0;
  F6502.RunMode:=rmReal;
  F6502.Running:=True;
end;

procedure TMyApplication.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$5000;
  FROM.ROMFile:='vt100.bin';
  FROM.OnROMLoad:=@ROMLoaded;
  FMemory.ROM[0]:=FROM;
  FROM.Active:=True;
  FHub:=T6502DeviceHub.Create(Self);
  FStorage:=T6502Storage.Create(Self);
  FStorage.Filename:='test.bin';
  FStorage.LoadOnStart:=True;
  FHub.Device[0]:=FStorage;
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
