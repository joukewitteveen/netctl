DESTDIR=
VERSION=2.5.0rc1
VPATH = doc

install:
	install -d $(DESTDIR)/usr/lib/network/{connections,hooks} \
				$(DESTDIR)/etc/network.d/{examples,hooks,interfaces} \
				$(DESTDIR)/etc/rc.d} \
	            $(DESTDIR)/var/run/network/{interfaces,profiles} \
				$(DESTDIR)/usr/share/man/{man5,man8} \
				
	# Documentation
	install -m644 examples/* $(DESTDIR)/etc/network.d/examples/
	install -m644 src/iftab $(DESTDIR)/etc/iftab
	install -m644 man/*.8 $(DESTDIR)/usr/share/man/man8
	# Libs
	install -m644 src/{network,wireless,8021x,globals} $(DESTDIR)/usr/lib/network
	install -m755 src/connections/* ${DESTDIR}/usr/lib/network/connections
	ln -s ethernet $(DESTDIR)/usr/lib/network/connections/ethernet-iproute
	# Hooks
	install -m755 src/hooks/* ${DESTDIR}/usr/lib/network/hooks/
	# Scripts
	install -Dm755 src/netcfg $(DESTDIR)/usr/bin/netcfg2
	install -Dm755 src/netcfg-menu $(DESTDIR)/usr/bin/netcfg-menu
	install -m755 wpa_actiond/netcfg-wpa_actiond{,-action} ifplugd/net-auto-wired $(DESTDIR)/usr/bin
	install -Dm755 ifplugd/netcfg.action $(DESTDIR)/etc/ifplugd/netcfg.action
	# Daemons
	install -m755 src/net-{profiles,rename} wpa_actiond/net-auto-wireless ifplugd/net-auto-wired $(DESTDIR)/etc/rc.d
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
	cd docs; \
	./make.sh

tarball: docs 
	sed -i "s/NETCFG_VER=.*/NETCFG_VER=$(VERSION)/g" src/netcfg
	mkdir -p netcfg-$(VERSION)
	cp -r src src-wireless ifplugd wpa_actiond examples contrib man Makefile LICENSE README netcfg-$(VERSION)
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
