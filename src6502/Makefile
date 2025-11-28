%.s: %.c
	cc65 $<

%.o: %.s
	ca65 -l code.lst $<

%.bin: %.c
	cc65 $<
	ca65 $(basename $<).s
	ld65 -C Asm/cfg/web6502.cfg -m $(basename $^).map -o $@ $(basename $^).o web6502.lib
	rm $(basename $<).s $(basename $<).o

clib.SYS: blog.c hdr.o
	cc65 $<
	ca65 $(basename $<).s
	ld65 -C clib.cfg -m clib.map -o $@ blog.o hdr.o web6502.lib
	rm $(basename $<).s $(basename $<).o

clean:
	rm -rf *.SYS output.hex *.bin
	rm -rf *.o 
	rm -rf *.map *.lst

all: portfolio.bin
