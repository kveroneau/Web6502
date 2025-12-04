////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit disk6502;

interface

uses Web6502;

procedure SetDisk(diskid: byte);
procedure LoadFile(fname: pointer; dest: pointer): boolean;
procedure LoadPRG(fname: pointer): pointer;
procedure LoadTextFile(fname, dest: pointer): boolean;
procedure LoadMarkdown(fname, dest: pointer): boolean;
procedure LoadTextFile(fname: pointer): boolean;
procedure GetFileType(fname: pointer): byte;
procedure SetCurDirectory(dirname: pointer);

implementation

procedure SetDisk(diskid: byte registerA);
begin
  asm 
	  LDY #0
    JMP $d106
  end; 
end;

procedure LoadFile(fname,dest: pointer): boolean;
begin
  asm 
    LDA dest
    STA $d100
    LDA dest+1
    STA $d101
	  LDA fname
    LDX fname+1
    LDY #$d2
    JSR $d106
    BNE ne1
    LDA #$ff
    RTS
ne1:
    LDA #0
  end; 
end;

procedure LoadPRG(fname: pointer): pointer;
begin
  asm 
	  LDA fname
    LDX fname+1
    LDY #$d4
    JSR $d106
    BNE ne1
    STX __H
    RTS
ne1:
    LDA #0
    STA __H
  end; 
end; 

procedure LoadTextFileAPI(fname: pointer; dest: pointer absolute $d100; api: byte registerY): boolean;
begin
  asm 
	  LDA fname
    LDX fname+1
    JSR $d106
    BNE ne1
    LDA #$ff
    RTS
ne1:
    LDA #0
  end; 
end;

procedure LoadTextFile(fname, dest: pointer): boolean;
begin
  Exit(LoadTextFileAPI(fname, dest, $d6));
end; 

procedure LoadMarkdown(fname, dest: pointer): boolean;
begin
  Exit(LoadTextFileAPI(fname, dest, $d7));
end;

procedure LoadTextFile(fname: pointer): boolean;
begin
  Exit(LoadTextFileAPI(fname, Word(0), $d8));
end;

procedure GetFileType(fname: pointer): byte;
begin
  asm 
	  LDA fname
    LDX fname+1
    LDY #$d0
    JMP $d106
  end;
end; 

procedure SetCurDirectory(dirname: pointer);
begin
  asm 
	  LDA dirname
    LDX dirname+1
    LDY #$d1
    JMP $d106
  end; 
end; 

end.

