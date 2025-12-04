////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit banks6502;

interface

procedure SetBank(bank: byte registerA);

implementation

var
  BANK_CTL: byte absolute $ffd1;

procedure SetBank(bank: byte registerA);
begin
  asm 
	  STA BANK_CTL; 
  end; 
end; 

end.
