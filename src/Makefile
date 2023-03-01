AS=asl -gnuerrors -cpu F3850 -relaxed
OBJCOPY=p2hex -k -l 32 -F Intel -r '$$-$$'

%.p:	%.ASM
	$(AS) -L -olist $*.LST $^
%.HEX:  %.p
	$(OBJCOPY) $^ $@

.PHONY: clean distclean

all: FAIRBUG.HEX

clean:
	-rm -f *.LST
distclean: clean
	-rm -f *.HEX
