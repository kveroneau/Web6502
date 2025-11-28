%.bin: %.o asm6502.o
	ld65 -C cfg/web6502.cfg -m $(basename $^).map -o $@ $^

KERNEL.SYS: kern6502.o
	ld65 -C cfg/kern6502.cfg -m kernel.map -o $@ $^
	cp $@ /mnt/Public/files/

ROM0.bin: bootrom.o
	ld65 -C cfg/bootrom.cfg -m bootrom.map -o $@ $^
	cp $@ /mnt/Public/
	cp $@ /mnt/Projects/Web6502/Website/

WEB6502.SYS: web6502.o
	ld65 -C cfg/boot6502.cfg -m boot.map -o $@ $^
	cp $@ /mnt/Public/files/

%.s: %.c
	cc65 $<

%.o: %.s
	ca65 -l code.lst $<

clean:
	rm -rf *.SYS output.hex *.bin
	rm -rf *.o 
	rm -rf *.map *.lst

os: ROM0.bin WEB6502.SYS
