# Makefile for netcfg documentation

MANPAGES = netcfg.8 netcfg-profiles.5
WEBPAGES = index.html features.html $(MANPAGES:%=%.html)

.PHONY: manpages website clean
manpages: $(MANPAGES)
website: website.tar.xz

$(MANPAGES): %: %.txt footer.txt
	a2x -d manpage -f manpage -a manversion=$(VERSION) $<

$(WEBPAGES): %.html: %.txt
	asciidoc -a disable-javascript -a linkcss -a max-width=960px $<

website.tar.xz: $(WEBPAGES)
	tar --transform "s%^%netcfg/%" -cJf $@ $^ -C /etc/asciidoc/stylesheets asciidoc.css

clean:
	-@rm -vf $(MANPAGES) $(WEBPAGES) website.tar.xz 2>/dev/null

