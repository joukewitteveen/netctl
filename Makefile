DESTDIR=
VERSION=2.7
VPATH = doc

.PHONY: install docs

install:
	# Configuration files
	install -d $(DESTDIR)/etc/network.d/{examples,hooks,interfaces}
	install -D -m644 config/netcfg $(DESTDIR)/etc/conf.d/netcfg
	install -m644 config/iftab $(DESTDIR)/etc/iftab
	install -m644 docs/examples/* $(DESTDIR)/etc/network.d/examples/
	# Documentation
	install -d $(DESTDIR)/usr/share/man/man5
	install -m644 docs/*.5 $(DESTDIR)/usr/share/man/man5
	install -d $(DESTDIR)/usr/share/man/man8
	install -m644 docs/*.8 $(DESTDIR)/usr/share/man/man8
	# Libs
	install -d $(DESTDIR)/usr/lib/network/{connections,hooks}
	install -m644 src/{network,rfkill,8021x,globals} $(DESTDIR)/usr/lib/network
	install -m755 src/connections/* $(DESTDIR)/usr/lib/network/connections
	ln -s wireless $(DESTDIR)/usr/lib/network/connections/wireless-dbus
	ln -s ethernet $(DESTDIR)/usr/lib/network/connections/ethernet-iproute
	# Hooks
	install -m755 src/hooks/* ${DESTDIR}/usr/lib/network/hooks/
	# Scripts
	install -d $(DESTDIR)/usr/bin
	install -m755 scripts/netcfg $(DESTDIR)/usr/bin/netcfg2
	ln -s netcfg2 $(DESTDIR)/usr/bin/netcfg
	install -m755 \
	    scripts/netcfg-menu \
	    scripts/netcfg-wpa_actiond \
	    scripts/netcfg-wpa_actiond-action \
	    $(DESTDIR)/usr/bin
	install -Dm755 scripts/ifplugd.action $(DESTDIR)/etc/ifplugd/netcfg.action
	# Daemons
	install -d $(DESTDIR)/etc/rc.d
	install -m755 \
	    rc.d/net-profiles \
	    rc.d/net-rename \
	    rc.d/net-auto-wireless \
	    rc.d/net-auto-wired \
	    $(DESTDIR)/etc/rc.d
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 \
	    systemd/net-auto-wireless.service \
	    systemd/net-auto-wired.service \
	    $(DESTDIR)/lib/systemd/system
	# Shell Completion
	install -Dm644 contrib/bash-completion $(DESTDIR)/etc/bash_completion.d/netcfg
	install -Dm644 contrib/zsh-completion $(DESTDIR)/usr/share/zsh/site-functions/_netcfg

install-wireless:
	install -d $(DESTDIR)/usr/lib/network/connections $(DESTDIR)/usr/bin \
				$(DESTDIR)/etc/rc.d
	install -m755 src-wireless/wireless-dbus $(DESTDIR)/usr/lib/network/connections
	install -m755 src-wireless/netcfg-auto-wireless $(DESTDIR)/usr/bin
	install -m755 src-wireless/net-auto $(DESTDIR)/etc/rc.d

install-docs: docs
	install -d $(DESTDIR)/usr/share/doc/netcfg/contrib
	install -m644 docs/*html $(DESTDIR)/usr/share/doc/netcfg/
	install -m644 contrib/* $(DESTDIR)/usr/share/doc/netcfg/contrib/
	
docs:
	cd docs && ./make.sh

tarball: docs 
	sed -i "s/NETCFG_VER=.*/NETCFG_VER=$(VERSION)/g" scripts/netcfg
	rm -rf netcfg-$(VERSION)
	mkdir -p netcfg-$(VERSION)
	cp -r docs config rc.d src scripts src-wireless systemd contrib Makefile LICENSE README netcfg-$(VERSION)
	tar -zcvf netcfg-$(VERSION).tar.gz netcfg-$(VERSION)
	rm -rf netcfg-$(VERSION)


upload:
	md5sum netcfg-$(VERSION)*gz > MD5SUMS.$(VERSION)
	scp netcfg-$(VERSION)*gz MD5SUMS.$(VERSION) archlinux.org:/srv/ftp/other/netcfg/

clean:	
	rm *gz
	rm -rf netcfg-*$(VERSION)
	rm -rf pkg
	rm MD5SUMS*
	rm docs/*html
