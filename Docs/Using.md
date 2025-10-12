# Using this Package

Firstly, you will need to have Lazarus installed along with pas2js, either download Lazarus from your Linux distro of choices repositories, or if don't use Linux, you can download an installer for the IDE for either Windows or macOS.  Modern versions of the Lazarus IDE have a menu option to download, install, and configure pas2js.  Once that is all ready to go, create a new *Web Browser Application* project, or use one of the Tests provided in this repo.  Open the `.lpk` package file in Lazarus to register it with the IDE, then compile away!

## Basic class use

You will need to use a few of the included classes to get started, here is a very minimal set-up:

```pascal
program Example;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, dom6502;

type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FSlots: T6502CardSlots;
    FDOM: T6502DOMOutput;
    FPRGFile: TBytesStream;
    procedure PRGLoaded(Sender: TObject);
  protected
    procedure DoRun; override;
  public
  end;

procedure TMyApplication.PRGLoaded(Sender: TObject);
begin
  F6502:=TMOS6502.Create(Self);
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FMemory.LoadPRG(FPRGFile);
  FreeAndNil(FPRGFile);
  FSlots:=T6502CardSlots.Create(Self);
  FDOM:=T6502DOMOutput.Create(Self);
  FDOM.Target:='content';
  FSlots.Card[0]:=FDOM;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  F6502.HaltVector:=$fff0;
  F6502.Running:=True;
end;

procedure TMyApplication.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FMemory.Active:=True;
  FPRGFile:=TBytesStream.Create;
  FPRGFile.LoadFromURL('hello.prg', True, @PRGLoaded);
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
```

The above example will load in a .PRG compatible binary program from the web server and place it in memory.
