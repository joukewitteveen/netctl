DESTDIR=
VERSION=2.1.0_B2


install:
	install -d $(DESTDIR)/usr/lib/network/ $(DESTDIR)/etc/network.d/examples \
	            $(DESTDIR)/var/run/network/{interfaces,profiles} \
	            $(DESTDIR)/usr/bin/ $(DESTDIR)/etc/rc.d/ \
				$(DESTDIR)/usr/man/{man5,man8}
	# Documentation
	install -m644 examples/*example $(DESTDIR)/etc/network.d/examples/
	install -m644 src/iftab $(DESTDIR)/etc/iftab
	install -m644 man/*.8 $(DESTDIR)/usr/man/man8
	# Libs
	install -m644 src/*subr $(DESTDIR)/usr/lib/network
	# 'Binaries'
	install -m755 src/netcfg $(DESTDIR)/usr/bin/netcfg2
	install -m755 src/netcfg-menu $(DESTDIR)/usr/bin/netcfg-menu
	# Daemons
	install -m755 src/net-profiles src/net-rename $(DESTDIR)/etc/rc.d
	
	
install-contrib:
	install -m755 contrib/netcfg-auto-wireless $(DESTDIR)/usr/bin
	install -m755 contrib/net-auto $(DESTDIR)/etc/rc.d

tarball: 
	sed -i "s/NETCFG_VER=.*/NETCFG_VER=$(VERSION)/g" src/netcfg
	mkdir -p netcfg-$(VERSION)
	cp -r src examples contrib man Makefile LICENSE README netcfg-$(VERSION)
	tar -zcvf netcfg-$(VERSION).tar.gz netcfg-$(VERSION)
	rm -rf netcfg-$(VERSION)
	md5sum netcfg-$(VERSION)*gz > MD5SUMS.$(VERSION)
    
pkg: tarball
	sed -i "s/pkgver=.*/pkgver=$(VERSION)/g" PKGBUILD
	makepkg
	rm -rf pkg
	rm -rf src/netcfg-$(VERSION)*
	md5sum netcfg-$(VERSION)*gz > MD5SUMS.$(VERSION)

upload: 
	scp netcfg-$(VERSION)*gz MD5SUMS.$(VERSION) archlinux.org:/home/ftp/other/netcfg/

clean:
	rm *gz
	rm -rf netcfg-$(VERSION)
	rm -rf pkg
	rm MD5SUMS*
