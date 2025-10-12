program Test2;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, rom6502, CardSlots6502, terminal6502;

type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FROM: T6502ROM;
    FSlots: T6502CardSlots;
    FTerm: T6502TerminalCard;
    FWebFile: TBytesStream;
    procedure BinLoaded(Sender: TObject);
  protected
    procedure DoRun; override;
  public
  end;

{$R ROM0.bin}

procedure TMyApplication.BinLoaded(Sender: TObject);
begin
  FMemory.LoadInto(FWebFile, $2000);
  FreeAndNil(FWebFile);
end;

procedure TMyApplication.DoRun;
begin
  FWebFile:=TBytesStream.Create;
  FWebFile.LoadFromURL('hello.bin', True, @BinLoaded);
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$f000;
  FROM.ROMFile:='rom0';
  FMemory.ROM[0]:=FROM;
  FROM.Active:=True;
  FMemory.Active:=True;
  F6502:=TMOS6502.Create(Self);
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.Address;
  FSlots:=T6502CardSlots.Create(Self);
  FTerm:=T6502TerminalCard.Create(Self);
  FSlots.Card[0]:=FTerm;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  F6502.HaltVector:=$fff0;
  F6502.RunMode:=rmReal;
  F6502.Running:=True;
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
