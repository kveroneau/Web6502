////////////////////////////////////////////
// New program created in 28-11-25}
////////////////////////////////////////////
unit rom6502;

{$STRING NULL_TERMINATED}
{$ORG $f100}
{$SET_DATA_ADDR '00DE-00FF'}
{$OUTPUTHEX 'ROM1.bin'}

interface

type
  pointer = word;
  string = array[] of char;

var
  cardio: Array[8] of byte absolute $c800;

procedure Write(s: pointer);

implementation

procedure Write(s: pointer);
begin
  asm 
	  LDA s
    LDX s+1
    jmp $f002
  end; 
end;



end.
