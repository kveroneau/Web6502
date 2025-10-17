#include <stdio.h>
#include <stdlib.h>
#include <6502.h>
#include <string.h>

#include "web6502.h"
#include "blog6502.h"
#include "router6502.h"

char* irqstack;

void LoadBlog(char* path){
    SetFilter("Path", path);
    SetTo(BlogTitle, 1);
    SetTo(BlogDate, 4);
    SetBlogContent("content");
}

unsigned char HandleRoute(){
    SetRealTime();
    LoadBlog(URL);
    return(IRQ_HANDLED);
}

void main(){
    char r;
    SetRealTime();
    irqstack=(char*)malloc(32);
    set_irq(HandleRoute, irqstack, 32);
    InitRouter(2);
    InitBlog(3);
    WriteTo("Printf can write to here too, wanna see?<br/>", 0);
    printf("See!  <i>This is from <code>printf</code> in the C Code!</i>\n");
    printf("<b>Heap Memory Available:</b> %d\n", _heapmemavail());
    WriteTo("Time to test <a href=\"#/index\">links</a>.\n", 0);
    r=CheckRoute();
    if (r == 0){
        PushRoute("/index");
    }
    IdleLoop();
}
