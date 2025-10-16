#include <stdio.h>
#include <stdlib.h>
#include <6502.h>

#include "web6502.h"

char* irqstack;

unsigned char HandleRoute(){
    WriteTo("Looks like IRQs seem to work.<br/>", 0);
    return(IRQ_HANDLED);
}

void main(){
    irqstack=(char*)malloc(32);
    set_irq(HandleRoute, irqstack, 32);
    SetTo("Test Title from C Code!", 1);
    SetTo("The modified area...", 4);
    WriteTo("Printf can write to here too, wanna see?<br/>", 0);
    printf("See!  <i>This is from <code>printf</code> in the C Code!\n");
    IdleLoop();
}
