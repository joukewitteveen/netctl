export VERSION = 1.0

PKG_CONFIG ?= pkg-config

sd_var = $(shell $(PKG_CONFIG) --variable=systemd$(1) systemd)
systemdsystemconfdir = $(call sd_var,systemconfdir)
systemdsystemunitdir = $(call sd_var,systemunitdir)

.PHONY: install tarball pkgbuild clean

install:
	# Documentation
	$(MAKE) -C docs install
	# Configuration files
	install -d $(DESTDIR)/etc/netctl/{examples,hooks,interfaces}
	install -m644 docs/examples/* $(DESTDIR)/etc/netctl/examples/
	# Libs
	install -d $(DESTDIR)/usr/lib/network/connections
	install -m644 src/lib/{globals,ip,rfkill,wpa} $(DESTDIR)/usr/lib/network/
	install -m644 src/lib/connections/* $(DESTDIR)/usr/lib/network/connections/
	install -m755 src/lib/{auto.action,network} $(DESTDIR)/usr/lib/network/
	# Scripts
	install -d $(DESTDIR)/usr/bin
	sed -e "s|@systemdsystemconfdir@|$(systemdsystemconfdir)|g" \
	    -e "s|@systemdsystemunitdir@|$(systemdsystemunitdir)|g" \
	    src/netctl.in > $(DESTDIR)/usr/bin/netctl
	chmod 755 $(DESTDIR)/usr/bin/netctl
	install -m755 \
	    src/netctl-auto \
	    src/wifi-menu \
	    $(DESTDIR)/usr/bin/
	install -Dm755 src/ifplugd.action $(DESTDIR)/etc/ifplugd/netctl.action
	# Services
	install -d $(DESTDIR)$(systemdsystemunitdir)
	install -m644 services/*.service $(DESTDIR)$(systemdsystemunitdir)/

tarball: netctl-$(VERSION).tar.xz
netctl-$(VERSION).tar.xz:
	$(MAKE) -B -C docs
	cp src/netctl.in{,.orig}
	sed -i "s|NETCTL_VERSION=.*|NETCTL_VERSION=$(VERSION)|" src/netctl.in
	git stash save -q
	git archive -o netctl-$(VERSION).tar --prefix=netctl-$(VERSION)/ stash
	git stash pop -q
	mv src/netctl.in{.orig,}
	tar --exclude-vcs --transform "s|^|netctl-$(VERSION)/|" --owner=root --group=root --mtime=./netctl-$(VERSION).tar -rf netctl-$(VERSION).tar docs/*.[1-8]
	xz netctl-$(VERSION).tar
	gpg --detach-sign $@

pkgbuild: PKGBUILD
PKGBUILD: netctl-$(VERSION).tar.xz contrib/PKGBUILD.in
	sed -e "s|@pkgver@|$(VERSION)|g" \
	    -e "s|@md5sum@|$(shell md5sum $< | cut -d ' ' -f 1)|" \
	    -e "s|@md5sum.sig@|$(shell md5sum $<.sig | cut -d ' ' -f 1)|" \
	    $(lastword $^) > $@

upload: netctl-$(VERSION).tar.xz
	scp $< $<.sig nymeria.archlinux.org:/srv/ftp/other/packages/netctl

clean:
	$(MAKE) -C docs clean
	-@rm -vf PKGBUILD *.tar.xz *.tar.xz.sig 2>/dev/null

