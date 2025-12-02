////////////////////////////////////////////
// New program created in 1-12-25}
////////////////////////////////////////////
unit rb6502;

interface

uses Web6502;

procedure ReadGlobal(key: pointer absolute $c102; dest: pointer absolute $c104);
procedure SetGlobal(key: pointer absolute $c102; v: pointer absolute $c104);
procedure SaveGlobals;

procedure AddFlag(flag: pointer absolute $c102);
procedure DelFlag(flag: pointer absolute $c102);
procedure HasFlag(flag: pointer absolute $c102): boolean;

implementation

var
  MODEL: byte absolute $c100;
  MKEY: word absolute $c102;
  MVAL: word absolute $c104;

procedure ReadGlobal(key: pointer absolute $c102; dest: pointer absolute $c104);
begin
  MODEL:=$f0;
end; 

procedure SetGlobal(key: pointer absolute $c102; v: pointer absolute $c104);
begin
  MODEL:=$f1;
end; 

procedure SaveGlobals;
begin
  MODEL:=$f2;
end; 

procedure AddFlag(flag: pointer absolute $c102);
begin
  MODEL:=$f3;
end; 

procedure DelFlag(flag: pointer absolute $c102);
begin
  MODEL:=$f4;
end;

procedure HasFlag(flag: pointer absolute $c102): boolean;
begin
  MODEL:=$f5;
  asm 
	  LDA $c101 
  end; 
end;

end.

