////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program blog;

uses Web6502, dom6502, router6502, blog6502;
{$ORG $5000}
{$OUTPUTHEX 'blog.bin'}
{$SET_DATA_ADDR '2000-2FFF'}

var
  title: array[60] of char;
  path: array[60] of char;
  date: array[120] of char;
  INITED: string = ' Initialized.';
  NOCARD: string = ' Interface Card not Detected.';
  IRQ_VEC: pointer absolute $fffe;
  DRAMA_MODE: boolean;

procedure DetectRouterCard: boolean;
var
  routecard: byte;
begin
  routecard:=FindCard($43);
  if routecard = 0 then
    Exit(False);
  end;
  InitRouter(routecard, @path);
  Write(@'WebRouter');
  WriteLn(@INITED);
end; 

procedure DetectBlogCard: boolean;
var
  blogcard: byte;
begin
  blogcard:=FindCard($8f);
  if blogcard = 0 then
    Exit(False);
  end;
  InitBlogCard(blogcard);
  BLOG_TITLE^:=@title;
  BLOG_PATH^:=@path;
  BLOG_DATE^:=@date;
  Write(@'Blog');
  WriteLn(@INITED);
end;

procedure SetTitle(s: pointer);
begin
  SetDOMElement(1);
  ClrScr;
  Write(s);
end;

procedure SetModified(s: pointer);
begin
  SetDOMElement(2);
  ClrScr;
  Write(s);
end;

procedure SetCtl(s: pointer);
begin
  SetDOMElement(3);
  ClrScr;
  Write(s);
end;

procedure ShowEntry;
begin
  SetTitle(@title);
  SetModified(@date);
  BlogSetContent(@'content');
  SetCtl(@'<a href="#/__prior">Previous</a> | <a href="#/__next">Next</a>');
  Write(@' | <a href="#/__index">Index</a>');
end;

procedure WriteBlogLink;
var
  lnk: array[255] of char;
begin
  SetRealTime(True);
  strcpy(@lnk, @'<li><a href="#');
  strcat(@lnk, @path);
  strcat(@lnk, @'">');
  strcat(@lnk, @title);
  strcat(@lnk, @'</a></li>');
  if DRAMA_MODE then
    SetRealTime(False);
  end;
  Write(@lnk);
end;

procedure ListBlog;
begin
  SetTitle(@'List of all Blog Pages');
  SetModified(@'Just a simple list of all the pages.');
  SetCtl(@'Loading List, please wait...');
  SetDOMElement(0);
  ClrScr;
  BlogFirst;
  Write(@'<ul>');
  repeat 
	  WriteBlogLink;
    BlogNext; 
  until BLOG_ERR^ = $ef;
  SetRealTime(False);
  Write(@'</ul>');
  SetCtl(@'<a href="#/__drama">Show List with more 6502 Drama</a>');
end; 

procedure LoadBlog;
begin
  if BlogLocate(@'Path', @path) then
    ShowEntry;
  elsif strcmp(@path, @'/__next') then
    BlogNext;
    PushRoute(@path);
    ShowEntry;
  elsif strcmp(@path, @'/__prior') then
    BlogPrior;
    PushRoute(@path); 
    ShowEntry;
  elsif strcmp(@path, @'/__index') then
    DRAMA_MODE:=False;
    ListBlog;
  elsif strcmp(@path, @'/__drama') then
    DRAMA_MODE:=True;
    ListBlog;
  else
    SetTitle(@'Page Not Found');
    SetModified(@'Web6502 Blog could not find that path.');
    SetDOMElement(0);
    ClrScr;
    Write(@'Return to <a href="#/index">index</a>?');
  end;
end;

procedure SysCall;
var
  cardid: byte absolute $c80a;
begin
  asm SEI end;
  {if cardid = $8f then}
    LoadBlog;
  {end;}
  cardid:=0;
  asm 
    CLI
    RTI
  end; 
end;

begin
  if DetectRouterCard = False then
    Write(@'WebRouter');
    Write(@NOCARD);
    Exit;
  end; 
  if DetectBlogCard = False then
    Write(@'Blog');
    Write(@NOCARD);
    Exit;
  end;
  DRAMA_MODE:=False;
  IRQ_VEC:=@SysCall;
  asm CLI end;
  if not CheckRoute then
    PushRoute(@'/__index');
  end;
  repeat
    
  until False;
  asm 
	  LDA #$42
    STA $fff0 
  end; 
end.

