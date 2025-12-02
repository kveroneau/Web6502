////////////////////////////////////////////
// New program created in 1-12-25}
////////////////////////////////////////////
program rabitboot;

uses Web6502, dom6502, disk6502;
{$BOOTLOADER $d8,$a2,$ff,$9a,$20,'COD_HL',$a9,$42,$8d,$f0,$ff}
{$ORG $400}
{$OUTPUTHEX 'WEB6502.SYS'}
  
begin
  WriteLn(@'RabitBoot v0.1 Started.');
  SetDiskCard(6);
  SetCurDirectory(@'System');
  if LoadFile(@'RBKERNEL.SYS', $801) then
    WriteLn(@'Starting Rabit Hole...');
    asm 
	    JMP $801
    end; 
  else
    WriteLn(@'Failed to load RBKERNEL.SYS!');
  end; 
  Exit;
end.

