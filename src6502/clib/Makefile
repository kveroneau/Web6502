SOURCES = crt0.s write.s

LIBRARY = web6502.lib

all: $(LIBRARY)

$(LIBRARY): $(SOURCES:.s=.o)
	ar65 a $(LIBRARY) $^
	cp $(LIBRARY) ../

%.o: %.s
	ca65 $<

clean:
	rm -rf $(SOURCES:.s=.o)
