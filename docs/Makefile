# Makefile for netcfg documentation

MANPAGES = netcfg.8 netcfg-profiles.5
WEBPAGES = index.html features.html $(MANPAGES:%=%.html)

.PHONY: all clean

all: $(MANPAGES) $(WEBPAGES)

$(MANPAGES): %: %.txt footer.txt
	a2x -d manpage -f manpage -a manversion=$(VERSION) $<

$(WEBPAGES): %.html: %.txt
	asciidoc -a version=$(VERSION) $<

clean:
	-@rm -vf $(MANPAGES) $(WEBPAGES) 2>/dev/null

