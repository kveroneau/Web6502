KERNEL.SYS: kern6502.o kernout.o kerndisk.o kernapi.o
	ld65 -C kern6502.cfg -m kernel.map -o $@ $^
	cp $@ /mnt/Public/files/

%.o: %.s
	ca65 -l code.lst $<

clean:
	rm -rf *.SYS
	rm -rf *.o
	rm -rf *.map *.lst

os: KERNEL.SYS
