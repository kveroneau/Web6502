////////////////////////////////////////////
// New program created in 29-11-25}
////////////////////////////////////////////
unit disk6502;

interface

uses Web6502;

procedure SetDiskCard(cardid: byte);
procedure LoadFile(fname: pointer; dest: pointer): boolean;
procedure LoadPRG(fname: pointer): pointer;
procedure LoadTextFile(fname, dest: pointer): boolean;
procedure LoadMarkdown(fname, dest: pointer): boolean;
procedure LoadTextFile(fname: pointer): boolean;
procedure GetFileType(fname: pointer): byte;

implementation

var
  DISK_CARD: ^byte absolute $24;
  DISK_TYPE: byte;
  DISK_ERR: ^byte;
  DISK_NAME: ^word;
  FILE_TYPE: ^byte;

procedure SetDiskCard(cardid: byte);
begin
  DISK_TYPE:=cardio[cardid];
  if DISK_TYPE = 0 then
    Exit;
  end; 
  DISK_CARD:=word(0);
  DISK_ERR:=word(1);
  DISK_NAME:=word(2);
  FILE_TYPE:=Word($a);
  asm
    CLC
	  LDA cardid 
    ADC #$c0
    STA DISK_CARD+1
    STA DISK_ERR+1
    STA DISK_NAME+1
    STA FILE_TYPE+1
  end;
end;

procedure SetFileName(s: pointer);
begin
  DISK_NAME^:=s;
end; 

procedure LoadFile(fname: pointer; dest: pointer): boolean;
begin
  if DISK_TYPE = 0 then
    Exit(False);
  end; 
  SetFileName(fname);
  asm 
	  LDY #4
    LDA dest
    STA (DISK_CARD), Y
    INY
    LDA dest+1
    STA (DISK_CARD), Y 
  end;
  DISK_CARD^:=$d2;
  repeat 
	 
  until DISK_CARD^ = 0;
  if DISK_ERR^ = 0 then
    Exit(True);
  else
    Exit(False);
  end; 
end;

procedure LoadPRG(fname: pointer): pointer;
begin
  if DISK_TYPE = 0 then
    Exit(Word(0));
  end;
  SetFileName(fname);
  DISK_CARD^:=$d4;
  repeat 
	 
  until DISK_CARD^ = 0;
  if DISK_ERR^ = 0 then
    asm
	     LDY #5
       LDA (DISK_CARD), Y
       STA __H
       DEY
       LDA (DISK_CARD), Y
       RTS
    end;
  else
    Exit(Word(0));
  end; 
end; 

procedure LoadTextFileAPI(fname, dest: pointer; api: byte): boolean;
begin
  if DISK_TYPE = 0 then
    Exit;
  end;
  SetFileName(fname);
  if api <> $d8 then
    asm 
	    LDY #4
      LDA dest
      STA (DISK_CARD), Y
      INY
      LDA dest+1
      STA (DISK_CARD), Y 
    end;
  end;
  DISK_CARD^:=api;
  repeat 
	 
  until DISK_CARD^ = 0;
  if DISK_ERR^ = 0 then
    Exit(True);
  else
    Exit(False);
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
  SetFileName(fname);
  DISK_CARD^:=$d0;
  Exit(FILE_TYPE^);
end; 

end.

