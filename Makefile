DESTDIR=
VERSION=2.2.0b2
VPATH = doc

install:
	install -d $(DESTDIR)/usr/lib/network/connections $(DESTDIR)/etc/network.d/examples \
	            $(DESTDIR)/var/run/network/{interfaces,profiles} \
	            $(DESTDIR)/usr/bin/ $(DESTDIR)/etc/rc.d/ \
				$(DESTDIR)/usr/share/man/{man5,man8}
	# Documentation
	install -m644 examples/* $(DESTDIR)/etc/network.d/examples/
	install -m644 src/iftab $(DESTDIR)/etc/iftab
	install -m644 man/*.8 $(DESTDIR)/usr/share/man/man8
	# Libs
	install -m644 src/{network,wireless,8021x} $(DESTDIR)/usr/lib/network
	install -m755 src/connections/* ${DESTDIR}/usr/lib/network/connections
	# 'Binaries'
	install -m755 src/netcfg $(DESTDIR)/usr/bin/netcfg2
	install -m755 src/netcfg-menu $(DESTDIR)/usr/bin/netcfg-menu
	# Daemons
	install -m755 src/net-profiles src/net-rename $(DESTDIR)/etc/rc.d

install-wireless:
	install -d $(DESTDIR)/usr/lib/network/connections $(DESTDIR)/usr/bin \
				$(DESTDIR)/etc/rc.d
	install -m755 src-wireless/wireless-dbus $(DESTDIR)/usr/lib/network/connections
	install -m755 src-wireless/netcfg-auto-wireless $(DESTDIR)/usr/bin
	install -m755 src-wireless/net-auto $(DESTDIR)/etc/rc.d

install-docs: docs
	install -d $(DESTDIR)/usr/share/doc/netcfg
	install -m644 doc/*html $(DESTDIR)/usr/share/doc/netcfg/
	
docs: doc/*
	for doc in $(?); do \
		pandoc $$doc -o $$doc.html;\
	done

tarball: 
	sed -i "s/NETCFG_VER=.*/NETCFG_VER=$(VERSION)/g" src/netcfg
	mkdir -p netcfg-$(VERSION)
	cp -r src src-wireless examples man Makefile LICENSE README netcfg-$(VERSION)
	tar -zcvf netcfg-$(VERSION).tar.gz netcfg-$(VERSION)
	rm -rf netcfg-$(VERSION)


upload: 
	md5sum netcfg-$(VERSION)*gz > MD5SUMS.$(VERSION)
	scp netcfg-$(VERSION)*gz MD5SUMS.$(VERSION) archlinux.org:/home/ftp/other/netcfg/

clean:
	rm doc/*html
	rm *gz
	rm -rf netcfg-*$(VERSION)
	rm -rf pkg
	rm MD5SUMS*
	
