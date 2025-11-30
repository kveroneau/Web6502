////////////////////////////////////////////
// New program created in 28-11-25}
////////////////////////////////////////////
program romtest;

{$BOOTLOADER $64,$01}
uses rom6502;

var
  jmp_vec: pointer absolute $f1fe;

procedure CallROM;
begin
  Write(@'ROM Code has been called. ');
  Write(@'A Second thing to write.');
end;

begin
  Write(@'; TestROM v0.1');
  asm 
	  LDA #$4C
    STA $F1FD
  end;
  jmp_vec:=@CallROM;
  Exit;
end.

