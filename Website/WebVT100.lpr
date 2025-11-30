program WebVT100;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, vt6502, storage6502, DeviceHub6502,
  banks6502, cffa6502, webdisk6502, env6502, table6502, jsondisk6502;

type

  { TWeb6502Terminal }

  TWeb6502Terminal = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FROM: T6502ROM;
    {$IFDEF TESTROM}
    FTestROM: T6502ROM;
    FTestROM2: T6502ROM;
    FBootApps: T6502JSONDisk;
    {$ENDIF}
    FSlots: T6502CardSlots;
    FTerm: TVT100Card;
    FCFFA1: T6502CFFA1Card;
    FDisk: T6502WebDisk;
    FEnv: T6502EnvCard;
    FTable: T6502TableCard;
  protected
    procedure DoRun; override;
  public
  end;

{$R ROM0.bin}
{$IFDEF TESTROM}
{$R ROM1.bin}
{$ENDIF}

{ TWeb6502Terminal }

procedure TWeb6502Terminal.DoRun;
begin
  F6502:=TMOS6502.Create(Self);
  FSlots:=T6502CardSlots.Create(Self);
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$f000;
  FROM.ROMFile:='rom0';
  FROM.Active:=True;
  FMemory.ROM[0]:=FROM;
  {$IFDEF TESTROM}
  FTestROM:=T6502ROM.Create(Self);
  FTestROM.Address:=$f100;
  FTestROM.ROMFile:='rom1';
  FTestROM.Active:=True;
  FMemory.ROM[1]:=FTestROM;
  FTestROM2:=T6502ROM.Create(Self);
  FTestROM2.Address:=$f200;
  FTestROM2.ROMFile:='rom1';
  FTestROM2.Active:=False;
  FMemory.ROM[2]:=FTestROM2;
  FBootApps:=T6502JSONDisk.Create(FSlots);
  FBootApps.DiskFile:='bootapps';
  FSlots.Card[4]:=FBootApps;
  {$ENDIF}
  FMemory.Active:=True;
  FTerm:=TVT100Card.Create(FSlots);
  FCFFA1:=T6502CFFA1Card.Create(FSlots);
  FDisk:=T6502WebDisk.Create(FSlots);
  FTable:=T6502TableCard.Create(FSlots);
  FEnv:=T6502EnvCard.Create(FSlots);
  GetEnvironmentList(FEnv.Vars, False);
  FSlots.Card[0]:=FTerm;
  FSlots.Card[1]:=FCFFA1;
  FSlots.Card[2]:=FEnv;
  FSlots.Card[3]:=FTable;
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
