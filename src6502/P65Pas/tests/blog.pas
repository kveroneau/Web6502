////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
program blog;

uses Web6502, dom6502, blog6502;
{$ORG $0801}
{$SET_DATA_ADDR '5000-5FFF'}

var
  title: array[60] of char;
  path: array[60] of char;
  date: array[60] of char;

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
  WriteLn(@'Blog Initialized.');
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

begin
  if DetectBlogCard = False then
    Write(@'Blog Interface Card not Detected.');
    Exit;
  end;
  BlogFirst;
  SetTitle(@title);
  SetModified(@date);
  BlogSetContent(@'content');
  asm 
	  LDA #$42
    STA $fff0 
  end; 
end.

