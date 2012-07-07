export VERSION = 2.8.6

.PHONY: install install-wireless install-docs docs tarball pkgbuild upload clean

install: install-docs
	# Configuration files
	install -d $(DESTDIR)/etc/network.d/{examples,interfaces}
	install -Dm644 config/netcfg $(DESTDIR)/etc/conf.d/netcfg
	install -m644 config/iftab $(DESTDIR)/etc/iftab
	install -m644 docs/examples/* $(DESTDIR)/etc/network.d/examples/
	# Libs
	install -d $(DESTDIR)/usr/lib/network/{connections,hooks}
	install -m644 src/{network,rfkill,8021x,globals} $(DESTDIR)/usr/lib/network/
	install -m755 src/connections/* $(DESTDIR)/usr/lib/network/connections/
	# Hooks
	install -m755 src/hooks/* ${DESTDIR}/usr/lib/network/hooks/
	# Scripts
	install -d $(DESTDIR)/usr/bin
	install -m755 \
	    scripts/netcfg \
	    scripts/netcfg-daemon \
	    scripts/netcfg-menu \
	    scripts/netcfg-wpa_actiond \
	    scripts/netcfg-wpa_actiond-action \
	    scripts/wifi-menu \
	    $(DESTDIR)/usr/bin/
	install -Dm755 scripts/ifplugd.action $(DESTDIR)/etc/ifplugd/netcfg.action
	install -Dm755 scripts/pm-utils $(DESTDIR)/usr/lib/pm-utils/sleep.d/50netcfg
	# Daemons
	install -Dm755 rc.d/net-set-variable $(DESTDIR)/etc/rc.d/functions.d/net-set-variable
	install -m755 \
	    rc.d/net-profiles \
	    rc.d/net-rename \
	    rc.d/net-auto-wired \
	    rc.d/net-auto-wireless \
	    $(DESTDIR)/etc/rc.d/
	install -d $(DESTDIR)/usr/lib/systemd/system
	install -m644 \
	    systemd/*.service \
	    $(DESTDIR)/usr/lib/systemd/system/

install-docs: docs
	install -d $(DESTDIR)/usr/share/man/{man5,man8}
	install -m644 docs/*.5 $(DESTDIR)/usr/share/man/man5/
	install -m644 docs/*.8 $(DESTDIR)/usr/share/man/man8/
	install -d $(DESTDIR)/usr/share/doc/netcfg/contrib
	install -m644 contrib/{*.hook,pm-utils.handler} $(DESTDIR)/usr/share/doc/netcfg/contrib/

docs:
	$(MAKE) -C $@

tarball: netcfg-$(VERSION).tar.xz
netcfg-$(VERSION).tar.xz: | docs
	cp scripts/netcfg{,.orig}
	sed -i "s/NETCFG_VER=.*/NETCFG_VER=$(VERSION)/" scripts/netcfg
	git stash save -q
	git archive -o netcfg-$(VERSION).tar --prefix=netcfg-$(VERSION)/ stash
	git stash pop -q
	mv scripts/netcfg{.orig,}
	tar --exclude-vcs --transform "s%^%netcfg-$(VERSION)/%" --owner=root --group=root --mtime=./netcfg-$(VERSION).tar -rf netcfg-$(VERSION).tar docs/*.[1-8]
	xz netcfg-$(VERSION).tar

pkgbuild: PKGBUILD
PKGBUILD: netcfg-$(VERSION).tar.xz
	sed -e "s/%pkgver%/$(VERSION)/" -e "s/%md5sum%/$(shell md5sum $< | cut -d ' ' -f 1)/" contrib/PKGBUILD > $@

upload: netcfg-$(VERSION).tar.xz
	md5sum $< > MD5SUMS.$(VERSION)
	scp $< MD5SUMS.$(VERSION) gerolde.archlinux.org:/srv/ftp/other/netcfg/

clean:
	$(MAKE) -C docs clean
	-@rm -vf PKGBUILD *.xz MD5SUMS.* 2>/dev/null

