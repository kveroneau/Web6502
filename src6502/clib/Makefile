SOURCES = crt0.s write.s web6502.s irq.s blog6502.s router6502.s dom6502.s webdisk6502.s

LIBRARY = web6502.lib

all: $(LIBRARY)

$(LIBRARY): $(SOURCES:.s=.o)
	ar65 a $(LIBRARY) $^
	cp $(LIBRARY) ../

%.o: %.s
	ca65 $<

clean:
	rm -rf $(SOURCES:.s=.o)
