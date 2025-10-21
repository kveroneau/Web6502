program WebVT100;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, vt6502, storage6502, DeviceHub6502,
  banks6502, cffa6502, webdisk6502, env6502;

type

  { TWeb6502Terminal }

  TWeb6502Terminal = class(TBrowserApplication)
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
    FDisk: T6502WebDisk;
    FEnv: T6502EnvCard;
  protected
    procedure DoRun; override;
  public
  end;

{$R ROM0.bin}

{ TWeb6502Terminal }

procedure TWeb6502Terminal.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$f000;
  FROM.ROMFile:='rom0';
  FROM.Active:=True;
  FMemory.ROM[0]:=FROM;
  FMemory.Active:=True;
  F6502:=TMOS6502.Create(Self);
  FSlots:=T6502CardSlots.Create(Self);
  FTerm:=TVT100Card.Create(Self);
  FCFFA1:=T6502CFFA1Card.Create(Self);
  FDisk:=T6502WebDisk.Create(Self);
  FEnv:=T6502EnvCard.Create(Self);
  GetEnvironmentList(FEnv.Vars, False);
  FSlots.Card[0]:=FTerm;
  FSlots.Card[1]:=FCFFA1;
  FSlots.Card[2]:=FEnv;
  FSlots.Card[6]:=FDisk;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.RST_VEC;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  FCFFA1.Compatibility:=True;
  F6502.HaltVector:=$fff0;
  F6502.Running:=True;
end;

var
  Application: TWeb6502Terminal;

begin
  Application:=TWeb6502Terminal.Create(nil);
  Application.Initialize;
  Application.Run;
end.
