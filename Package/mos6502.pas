unit MOS6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, timer, Memory6502, Dev6502;

type

  E6502Error = class(Exception);

  TRunMode = (rmTimer, rmReal);

  { TMOS6502 }

  TMOS6502 = class(TComponent)
  private
    FActive: Boolean;
    FMemory: T6502Memory;
    FDevice: T6502Device;
    FResetVector, FHaltVector: word;
    FRunning: Boolean;
    FTimer: TTimer;
    FRunMode: TRunMode;
    function GetPC: word;
    function GetRegA: byte;
    function GetRegAX: word;
    function GetRegX: byte;
    function GetRegY: byte;
    procedure CheckRunning;
    procedure RunCycle(Sender: TObject);
    procedure SetActive(AValue: Boolean);
    procedure SetHaltVector(AValue: word);
    procedure SetMemory(AValue: T6502Memory);
    procedure SetPC(AValue: word);
    procedure SetRegA(AValue: byte);
    procedure SetRegAX(AValue: word);
    procedure SetRegX(AValue: byte);
    procedure SetRegY(AValue: byte);
    procedure SetResetVector(AValue: word);
    procedure SetRunning(AValue: Boolean);
  public
    property Active: Boolean read FActive write SetActive;
    property Memory: T6502Memory read FMemory write SetMemory;
    property Device: T6502Device read FDevice write FDevice;
    property Running: Boolean read FRunning write SetRunning;
    property RunMode: TRunMode read FRunMode write FRunMode;
    property ResetVector: word read FResetVector write SetResetVector;
    property HaltVector: word read FHaltVector write SetHaltVector;
    property PC: word read GetPC write SetPC;
    property RegA: byte read GetRegA write SetRegA;
    property RegX: byte read GetRegX write SetRegX;
    property RegY: byte read GetRegY write SetRegY;
    property RegAX: word read GetRegAX write SetRegAX;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

const
  VEC_NMI = $fffa;
  VEC_RST = $fffc;
  VEC_IRQ = $fffe;

{ JavaScript bindings for 6502cpu.js }
procedure jsResetCPU; external name 'window.cpu6502.resetCPU';
procedure jsStepCPU; external name 'window.cpu6502.step';
procedure jsSetPC(v: word); external name 'window.cpu6502.setPC';
function jsGetPC: word; external name 'window.cpu6502.getPC';
procedure jsSetSP(v: byte); external name 'window.cpu6502.setSP';
function jsGetSP: byte; external name 'window.cpu6502.getSP';
procedure jsSetA(v: byte); external name 'window.cpu6502.setA';
function jsGetA: byte; external name 'window.cpu6502.getA';
procedure jsSetX(v: byte); external name 'window.cpu6502.setX';
function jsGetX: byte; external name 'window.cpu6502.getX';
procedure jsSetY(v: byte); external name 'window.cpu6502.setY';
function jsGetY: byte; external name 'window.cpu6502.getY';
procedure jsIRQ; external name 'window.cpu6502.irq';
procedure jsNMI; external name 'window.cpu6502.nmi';

{ TMOS6502 }

procedure TMOS6502.RunCycle(Sender: TObject);
begin
  jsStepCPU;
  FDevice.DeviceRun;
  CheckRunning;
  if FRunMode = rmReal then
  begin
    WriteLn('Entering Real-time...');
    repeat
      jsStepCPU;
      FDevice.DeviceRun;
      CheckRunning;
    until (not FRunning) or (FRunMode = rmTimer);
  end;
end;

function TMOS6502.GetPC: word;
begin
  Result:=jsGetPC;
end;

function TMOS6502.GetRegA: byte;
begin
  Result:=jsGetA;
end;

function TMOS6502.GetRegAX: word;
begin
  Result:=(jsGetX shl 8)+jsGetA;
end;

function TMOS6502.GetRegX: byte;
begin
  Result:=jsGetX;
end;

function TMOS6502.GetRegY: byte;
begin
  Result:=jsGetY;
end;

procedure TMOS6502.CheckRunning;
begin
  if FHaltVector = 0 then
    Exit;
  if FMemory.Memory[FHaltVector] = $42 then
    FRunning:=False;
end;

procedure TMOS6502.SetActive(AValue: Boolean);
begin
  if FActive=AValue then Exit;
  if AValue then
  begin
    if not Assigned(FMemory) then
      raise E6502Error.Create('No 6502 Memory is assigned.');
    jsResetCPU;
    FMemory.SetWord(VEC_RST, FResetVector);
    jsSetPC(FMemory.GetWord(VEC_RST));
    FDevice.Memory:=FMemory;
  end
  else if FRunning then
    Running:=False;
  FActive:=AValue;
end;

procedure TMOS6502.SetHaltVector(AValue: word);
begin
  if FHaltVector=AValue then Exit;
  FMemory.Memory[AValue]:=0;
  FHaltVector:=AValue;
end;

procedure TMOS6502.SetMemory(AValue: T6502Memory);
begin
  if FMemory=AValue then Exit;
  if not FActive then
    FMemory:=AValue
  else
    raise E6502Error.Create('Cannot set memory on active CPU.');
end;

procedure TMOS6502.SetPC(AValue: word);
begin
  jsSetPC(AValue);
end;

procedure TMOS6502.SetRegA(AValue: byte);
begin
  jsSetA(AValue);
end;

procedure TMOS6502.SetRegAX(AValue: word);
begin
  jsSetA(AValue and $ff);
  jsSetX(AValue shr 8);
end;

procedure TMOS6502.SetRegX(AValue: byte);
begin
  jsSetX(AValue);
end;

procedure TMOS6502.SetRegY(AValue: byte);
begin
  jsSetY(AValue);
end;

procedure TMOS6502.SetResetVector(AValue: word);
begin
  if FResetVector=AValue then Exit;
  if Assigned(FMemory) then
    FMemory.SetWord(VEC_RST, AValue);
  FResetVector:=AValue;
end;

procedure TMOS6502.SetRunning(AValue: Boolean);
begin
  if FRunning=AValue then Exit;
  if not FActive then
    raise E6502Error.Create('Cannot set running on inactive CPU!');
  FTimer.Enabled:=AValue;
  FRunning:=AValue;
end;

constructor TMOS6502.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimer:=TTimer.Create(Self);
  FTimer.Enabled:=False;
  FTimer.Interval:=100;
  FTimer.OnTimer:=@RunCycle;
  FMemory:=Nil;
  FRunMode:=rmTimer;
  FHaltVector:=0;
end;

end.

