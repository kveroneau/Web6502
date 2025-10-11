program Test1;

{$mode objfpc}

uses
  BrowserApp, JS, Classes, SysUtils, Web, rtl.BrowserLoadHelper, MOS6502,
  Memory6502, CardSlots6502, Card6502, rom6502;

type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    F6502: TMOS6502;
    FMemory: T6502Memory;
    FSlots: T6502CardSlots;
    FTestCard: T6502Card;
    FWebFile: TBytesStream;
    FROM: T6502ROM;
    procedure PRGLoaded(Sender: TObject);
    procedure ROMLoaded(Sender: TObject);
    procedure CardInit(Sender: TObject);
    procedure CardTest(Sender: TObject);
  protected
    procedure DoRun; override;
  public
  end;

{$R ROM0.bin}

procedure TMyApplication.PRGLoaded(Sender: TObject);
begin
  WriteLn('PRG Loaded.');
  FMemory.LoadInto(FWebFile, F6502.ResetVector);
  FWebFile.Free;
  FWebFile:=Nil;
  F6502.Running:=True;
end;

procedure TMyApplication.ROMLoaded(Sender: TObject);
begin
  FMemory.Active:=True;
  WriteLn('ROM Loaded: ', FMemory.Memory[$2000]);
  F6502:=TMOS6502.Create(Self);
  FSlots:=T6502CardSlots.Create(Self);
  FTestCard:=T6502Card.Create(Self);
  FTestCard.OnInitCard:=@CardInit;
  FTestCard.OnRunCard:=@CardTest;
  FSlots.Card[0]:=FTestCard;
  F6502.Memory:=FMemory;
  F6502.ResetVector:=FROM.Address;
  F6502.Device:=FSlots;
  F6502.Active:=True;
  F6502.Running:=True;
end;

procedure TMyApplication.CardInit(Sender: TObject);
begin
  {FWebFile:=TBytesStream.Create;
  FWebFile.LoadFromURL('test1.prg', True, @PRGLoaded);}

  Writeln('Hello World from CardInit!');
end;

procedure TMyApplication.CardTest(Sender: TObject);
var
  op: byte;
begin
  if not FROM.Active then
    Exit;
  op:=FTestCard.Memory[0];
  WriteLn('Test Card Op Code: ',op);
  if op <> 0 then
    F6502.Running:=False;
end;

procedure TMyApplication.DoRun;
begin
  FMemory:=T6502Memory.Create(Self);
  FROM:=T6502ROM.Create(Self);
  FROM.Address:=$2000;
  FROM.ROMFile:='test1.prg';
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
