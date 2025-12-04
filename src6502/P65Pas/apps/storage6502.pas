////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit storage6502;

interface

procedure SaveMemory;
procedure LoadMemory;

implementation

var
  DEV_CTL: byte absolute $ffd0;

procedure SaveMemory;
begin
  DEV_CTL:=$60;
end; 

procedure LoadMemory;
begin
  DEV_CTL:=$40;
end; 

end.

