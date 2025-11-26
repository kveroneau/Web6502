program Portfolio;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, dom6502, router6502, blog6502, webdisk6502;

type

  { TMyPortfolio }

  TMyPortfolio = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FSlots: T6502CardSlots;
    FDOM: T6502DOMOutput;
    FROM: T6502ROM;
    FRouter: T6502WebRouterCard;
    FDisk: T6502WebDisk;
  protected
    procedure DoRun; override;
  public
  end;

{$R ROM0.bin}

{ TMyPortfolio }

procedure TMyPortfolio.DoRun;
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
  FDOM:=T6502DOMOutput.Create(Self);
  FDOM.AddElement('content');
  FDOM.AddElement('title');
  FDOM.AddElement('modified');
  FDisk:=T6502WebDisk.Create(FSlots);
  FRouter:=T6502WebRouterCard.Create(Self);
  FSlots.Card[0]:=FDOM;
  FSlots.Card[1]:=FRouter;
  FSlots.Card[6]:=FDisk;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.RST_VEC;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  F6502.HaltVector:=$fff0;
  FMemory.LoadString('portfolio.bin'+#0, $ff00);
  F6502.Running:=True;
end;

var
  Application: TMyPortfolio;

begin
  Application:=TMyPortfolio.Create(nil);
  Application.Initialize;
  Application.Run;
end.
