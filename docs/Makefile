# Makefile for netctl documentation

MANPAGES = netctl.1 netctl.profile.5 netctl.special.7

.PHONY: manpages install $(MANPAGES:=-install) clean
manpages: $(MANPAGES)
$(MANPAGES): %: %.txt
	a2x -d manpage -f manpage -a manversion=$(VERSION) $<

install: $(MANPAGES:=-install)
$(MANPAGES:=-install): %-install: %
	install -Dm644 $< $(DESTDIR)/usr/share/man/man$(subst .,,$(suffix $<))/$<

clean:
	-@rm -vf $(MANPAGES) 2>/dev/null

