unit cffa6502;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Card6502, Web;

type

  { T6502CFFA1Card }

  T6502CFFA1Card = class(T6502Card)
  private
    FCompatibility: Boolean;
    FZPSave: TBytes;
    FCFFAError: string;
    FCFIdx: byte;
    procedure SetCompatibility(AValue: Boolean);
    procedure WriteOut(msg: string);
    procedure CFFA1ReadDir;
    procedure CFFA1SaveFile;
    procedure CFFA1LoadFile;
    procedure SaveZP;
    procedure LoadZP;
  protected
    function GetCardType: byte; override;
  public
    property Compatibility: Boolean read FCompatibility write SetCompatibility;
    procedure CardRun; override;
  end;

implementation

procedure jsWriteMemory(addr: word; data: TBytes; isROM: boolean); external name 'window.cpu6502.writeMemory';
function jsReadMemory(addr, size: word; ignoreROM: boolean): TBytes; external name 'window.cpu6502.readMemory';

{ T6502CFFA1Card }

procedure T6502CFFA1Card.SetCompatibility(AValue: Boolean);
begin
  if FCompatibility=AValue then Exit;
  if AValue then
  begin
    with SysMemory do
    begin
      Memory[$9006]:=$60;
      Memory[$9009]:=$60;
      LoadString(#$18#$8e#$00#$91#$60, $900c);
      LoadString(#$a9#$35#$8d#$00#$91#$60, $9135);
      LoadString(#$a9#$40#$8d#$00#$91#$60, $9140);
      LoadString(#$cf#$fa, $afdc);
    end;
  end;
  FCompatibility:=AValue;
end;

procedure T6502CFFA1Card.WriteOut(msg: string);
begin
  SysMemory.LoadString(msg+#0, CardAddr+$80);
  SysMemory.SetWord($c002, CardAddr+$80);
  SysMemory.Memory[$c000]:=$80;
end;

procedure T6502CFFA1Card.CFFA1ReadDir;
var
  title: string;
begin
  if FCFIdx > window.localStorage.length then
  begin
    SysMemory.SetWord($0b, $0000);
    Exit;
  end;
  title:=window.localStorage.key(FCFIdx);
  Inc(FCFIdx);
  SysMemory.LoadString(title+#0, CardAddr+$80);
  SysMemory.SetWord($0b, CardAddr+$80);
end;

procedure T6502CFFA1Card.CFFA1SaveFile;
var
  title: string;
  dest, fsize: word;
begin
  dest:=SysMemory.GetWord($00);
  title:=SysMemory.GetString(SysMemory.GetWord($02)+1);
  fsize:=SysMemory.GetWord($09);
  window.localStorage.setItem(title, SysMemory.SaveString(dest, fsize));
end;

procedure T6502CFFA1Card.CFFA1LoadFile;
var
  title, data, datax: string;
  dest: word;
begin
  dest:=SysMemory.GetWord($00);
  title:=SysMemory.GetString(SysMemory.GetWord($02)+1);
  data:=window.localStorage.getItem(title);
  datax:=data+'x';
  if datax = 'nullx' then
  begin
    FCFFAError:='?FILE NOT FOUND';
    SEC
  end
  else
    SysMemory.LoadString(data, dest);
end;

procedure T6502CFFA1Card.SaveZP;
begin
  FZPSave:=jsReadMemory($0000, $ff, True);
end;

procedure T6502CFFA1Card.LoadZP;
begin
  jsWriteMemory($0000, FZPSave, False);
end;

function T6502CFFA1Card.GetCardType: byte;
begin
  Result:=$cf;
end;

procedure T6502CFFA1Card.CardRun;
var
  op: byte;
begin
  op:=0;
  if FCompatibility then
    op:=SysMemory.Memory[$9100];
  if op = 0 then
    op:=Memory[0];
  if op = 0 then
    Exit;
  case op of
    $04: WriteOut(#$a#$d+FCFFAError);
    $10: FCFIdx:=0;
    $12: CFFA1ReadDir;
    $20: CFFA1SaveFile;
    $22: CFFA1LoadFile;
    $2e: window.localStorage.clear;
    $35: LoadZP;
    $40: SaveZP;
  end;
  if FCompatibility then
    SysMemory.Memory[$9100]:=0;
  Memory[0]:=0;
end;

end.

