////////////////////////////////////////////
// New program created in 30-11-25}
////////////////////////////////////////////
unit blog6502;

interface

uses Web6502;

var
  BLOG_TITLE: ^word;
  BLOG_PATH: ^word;
  BLOG_DATE: ^word;
  BLOG_ERR: ^byte;

procedure InitBlogCard(cardid: byte);
procedure BlogFirst;
procedure BlogLast;
procedure BlogNext;
procedure BlogPrior;

procedure BlogClearFilter;
procedure BlogSetFilter(afield, avalue: pointer);
procedure BlogLocate(afield, avalue: pointer): boolean;

procedure BlogSetContent(domid: pointer);

implementation

var
  BLOG_CARD: ^byte absolute $30;
  BLOG_FLD: ^word;
  BLOG_VALUE: ^word;

procedure InitBlogCard(cardid: byte);
begin
  if cardio[cardid] <> $8f then
    Exit;
  end;
  BLOG_CARD:=Word(0);
  BLOG_ERR:=Word(1);
  BLOG_FLD:=Word(2);
  BLOG_VALUE:=Word(4);
  BLOG_TITLE:=Word($20);
  BLOG_PATH:=Word($22);
  BLOG_DATE:=Word($24);
  asm 
	  CLC
    LDA cardid
    ADC #$c0
    STA BLOG_CARD+1
    STA BLOG_ERR+1
    STA BLOG_FLD+1
    STA BLOG_VALUE+1
    STA BLOG_TITLE+1
    STA BLOG_PATH+1
    STA BLOG_DATE+1
  end; 
end;

procedure BlogFirst;
begin
  BLOG_CARD^:=$10;
end; 

procedure BlogLast;
begin
  BLOG_CARD^:=$11;
end; 

procedure BlogNext;
begin
  BLOG_CARD^:=$12;
end; 

procedure BlogPrior;
begin
  BLOG_CARD^:=$13;
end; 

procedure BlogClearFilter;
begin
  BLOG_CARD^:=$20;
end;

procedure BlogSetFilter(afield, avalue: pointer);
begin
  BLOG_FLD^:=afield;
  BLOG_VALUE^:=avalue;
  BLOG_CARD^:=$21;
end;

procedure BlogLocate(afield, avalue: pointer): boolean;
begin
  BLOG_FLD^:=afield;
  BLOG_VALUE^:=avalue;
  BLOG_CARD^:=$22;
  if BLOG_ERR^ = $7f then
    Exit(True);
  else
    Exit(False);
  end; 
end;

procedure BlogSetContent(domid: pointer);
begin
  BLOG_FLD^:=domid;
  BLOG_CARD^:=$80;
end; 

end.
