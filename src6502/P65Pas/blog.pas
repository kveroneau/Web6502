////////////////////////////////////////////
// New program created in 15-10-25}
////////////////////////////////////////////
program blog;
{$BOOTLOADER $20,'COD_HL',$a9,$42,$8d,$f0,$ff}
{$STRING NULL_TERMINATED}
{$ORG $5000}
{$SET_DATA_ADDR '2000-2FFF'}

{$OUTPUTHEX 'blog.bin'}

type
  pointer = word;
  string = array[] of char;

var
  OUT: byte absolute $c000;
  KIN: char absolute $c104;
  CTX: byte absolute $c100;
  IRQ_VEC: pointer absolute $fffe;
  SYS_API: byte absolute $fff0;
  URL: pointer absolute $c220;
  BAPI: byte absolute $c300;
  BCONTENT: pointer absolute $c302;
  
  BTITLE: pointer absolute $c320;
  BPATH: pointer absolute $c322;
  BDATE: pointer absolute $c324;
  BlogTitle: Array[60] of char;
  BlogPath: Array[40] of char;
  BlogDate: Array[60] of char;
  
procedure Write(s: pointer absolute $c002);
begin
  OUT:=$80;
end; 

procedure TWrite(s: pointer absolute $c102);
begin
  CTX:=$82;
  CTX:=$80;
end; 

procedure MWrite(s: pointer absolute $c402);
var
  api: byte absolute $c400;
begin
  api:=$82;
  api:=$80;
end; 

procedure SetFilter(field: pointer absolute $c302; value: pointer absolute $c304);
begin
  BAPI:=$21;
end; 

procedure PushBlog(s: pointer absolute $c202);
var
  api2: byte absolute $c200;
begin
  api2:=$40;  
end; 

procedure LoadBlog(path: pointer);
begin
  SetFilter(@'Path', path);
  TWrite(@BlogTitle);
  MWrite(@BlogDate);
  BCONTENT:=@'content';
  BAPI:=$80;
end; 

procedure SysCall;
var
  cardid: byte absolute $c80a;
begin
  asm SEI end;
  {if cardid = $8f then}
    LoadBlog(URL);
  {end;}
  cardid:=0;
  asm 
    CLI
    RTI
  end; 
end; 

procedure CheckRoute: boolean;
var
  api2: byte absolute $c200;
  res: boolean absolute $c201;
begin
  api2:=$41;
  exit(res);
end; 

procedure IdleLoop;
begin
  repeat 
    {SYS_API:=$40;
    SYS_API:=$41;}
  until KIN = 'q';
end; 

begin
  MWrite(@'Web6502 Started.');
  IRQ_VEC:=@SysCall;
  BTITLE:=@BlogTitle;
  BPATH:=@BlogPath;
  BDATE:=@BlogDate;
  asm CLI end;
  if not CheckRoute then
    PushBlog(@'/index');
  end;
  IdleLoop;
  Write(@'Program terminated.');
  Exit;
end.

