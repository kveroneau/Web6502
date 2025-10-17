program Website;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, rom6502, dom6502, router6502, blog6502, Status6502,
  DeviceHub6502;

type

  { TWeb6502Site }

  TWeb6502Site = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FSlots: T6502CardSlots;
    FDOM: T6502DOMOutput;
    FTitle: T6502DOMOutput;
    FModified: T6502DOMOutput;
    FROM: T6502ROM;
    FRouter: T6502WebRouterCard;
    FBlog: T6502WebsiteBlogCard;
    FStatus: T6502StatusDevice;
    FHub: T6502DeviceHub;
    procedure ROMLoaded(Sender: TObject);
  protected
    procedure DoRun; override;
  public
  end;

{ TWeb6502Site }

procedure TWeb6502Site.ROMLoaded(Sender: TObject);
begin
  FMemory.Active:=True;
  F6502:=TMOS6502.Create(Self);
  FSlots:=T6502CardSlots.Create(Self);
  FDOM:=T6502DOMOutput.Create(Self);
  FDOM.Target:='content';
  FTitle:=T6502DOMOutput.Create(Self);
  FTitle.Target:='title';
  FModified:=T6502DOMOutput.Create(Self);
  FModified.Target:='modified';
  FRouter:=T6502WebRouterCard.Create(Self);
  FBlog:=T6502WebsiteBlogCard.Create(Self);
  FSlots.Card[0]:=FDOM;
  FSlots.Card[1]:=FTitle;
  FSlots.Card[2]:=FRouter;
  FSlots.Card[3]:=FBlog;
  FSlots.Card[4]:=FModified;
  FStatus:=T6502StatusDevice.Create(Self);
  FHub:=T6502DeviceHub.Create(Self);
  FHub.Device[0]:=FSlots;
  FHub.Device[1]:=FStatus;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.Address;
  F6502.Device:=FHub;
  F6502.Active:=True;
  F6502.HaltVector:=$fff0;
  {F6502.RunMode:=rmReal;}
  F6502.Running:=True;
end;

procedure TWeb6502Site.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$5000;
  FROM.ROMFile:='blog.bin';
  FROM.OnROMLoad:=@ROMLoaded;
  FMemory.ROM[0]:=FROM;
  FROM.Active:=True;
end;

var
  Web6502Site: TWeb6502Site;

begin
  Web6502Site:=TWeb6502Site.Create(Nil);
  Web6502Site.Initialize;
  Web6502Site.Run;
end.
