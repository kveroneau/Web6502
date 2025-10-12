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

## Creating 6502 compatible programs

There are technically a few approaches you could take to build compatible 6502 programs for use with *Web6502*, here is a list of potential examples:

  * Create devices to mimic a real world retro 6502 machine, such as the *Commodore 64*, and use compatible assemblers and compilers targetted to that specific system.
    - You may also need to either source a C64 ROM, or build your own shim ROM.
    - ROM routines could just be emulated via a virtual device to speed up overall emulation.
    - Compatible Canvas routines, or a compatible HTML5 terminal would be needed to emulate I/O.
  * Use the included devices, cards, and APIs.  Craft your custom 6502 programs to target this web-based system, and extend it with your own devices and cards as needed.
    - A **cc65** compatible library and development kit will soon be provided to allow you to create compatible 6502 programs in the popular C programming language.  You will need to download and configure *cc65* in order to use it.
  * Create a completely custom 6502 system with APIs to your personal liking, and hand assemble the programs yourself.

Once the *C Library* is made available via this repository, it will also have some basic examples which you can compile yourself to learn how to build your own using C.  This is also a really fun and safe way to learn the *C Programming Language*, as all the running C code is both entirely contained inside a virtual 6502 emulator, which is contained within your web browser.
