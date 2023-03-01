AS=asm -v -C F3850

%.HEX:	%.ASM
	$(AS) -l $*.LST -o $@ $^

.PHONY: clean distclean

all: FAIRBUG.HEX

clean:
	-rm -f *.LST
distclean: clean
	-rm -f *.HEX
