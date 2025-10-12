program Test3;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, vt6502;

type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FROM: T6502ROM;
    FSlots: T6502CardSlots;
    FTerm: TVT100Card;
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
  FSlots.Card[0]:=FTerm;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.Address;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  F6502.HaltVector:=$fff0;
  {F6502.RunMode:=rmReal;}
  F6502.Running:=True;
end;

procedure TMyApplication.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$f000;
  FROM.ROMFile:='vt100.bin';
  FROM.OnROMLoad:=@ROMLoaded;
  FMemory.ROM[0]:=FROM;
  FROM.Active:=True;
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
