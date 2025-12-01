////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit router6502;

interface

uses Web6502;

procedure InitRouter(cardid: byte; urlbuf: pointer);
procedure PushRoute(path: pointer);
procedure CheckRoute: boolean;

implementation

var
  ROUTER_CARD: ^byte absolute $2e;

procedure InitRouter(cardid: byte; urlbuf: pointer);
begin
  if cardio[cardid] <> $43 then
    Exit;
  end;
  ROUTER_CARD:=Word(0);
  asm 
	  CLC
    LDA cardid
    ADC #$c0
    STA ROUTER_CARD+1
    LDY #$20
    LDA urlbuf
    STA (ROUTER_CARD), Y
    INY
    LDA urlbuf+1
    STA (ROUTER_CARD), Y
  end; 
end; 

procedure PushRoute(path: pointer);
begin
  asm 
	  LDY #2
    LDA path
    STA (ROUTER_CARD), Y
    INY
    LDA path+1
    STA (ROUTER_CARD), Y
  end;
  ROUTER_CARD^:=$40;
end; 

procedure CheckRoute: boolean;
begin
  ROUTER_CARD^:=$41;
  asm 
	  LDY #1
    LDA (ROUTER_CARD), Y 
  end; 
end; 

end.
