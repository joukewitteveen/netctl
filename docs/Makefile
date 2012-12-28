# Makefile for netctl documentation

MANPAGES = netctl.1 netctl.profile.5 netctl.special.7

.PHONY: manpages clean
manpages: $(MANPAGES)
$(MANPAGES): %: %.txt
	a2x -d manpage -f manpage -a manversion=$(VERSION) $<

clean:
	-@rm -vf $(MANPAGES) 2>/dev/null

