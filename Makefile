#!/usr/bin/make -f
# $Id$

VER=$(shell grep VERSION vcs | head -n1 | sed 's/\#.*//' | sed -r 's/.*"(.*)".*/\1/g')

all:
	@echo "Use $(MAKE) dist"

check-no-svn:
	@if [ -d .svn ]; then echo "Don't release from SVN working copy" ; false ; fi

check-rel:
	@if head -n50 vcs | grep -q 'RELEASE=0' ; then \
		echo 'RELEASE is set to 0!' ; false ; fi

prep:
	cp vcs CHANGELOG debian-package/
	cp vcs rpm-package/

dist: check-rel check-no-svn prep gz bz2 plaintext changelog deb rpm cleanup

gz:
	cp vcs vcs-$(VER)
	chmod -x vcs-$(VER)
	gzip -9 vcs-$(VER)

bz2:
	cp vcs vcs-$(VER)
	chmod -x vcs-$(VER)
	bzip2 -9 vcs-$(VER)

plaintext:
	cp vcs vcs-$(VER)
	chmod -x vcs-$(VER)

changelog:
	gzip -9 CHANGELOG
	gzip -dc CHANGELOG.gz > CHANGELOG

cleanup:
	$(RM) vcs Makefile *.changes
	$(RM) -r debian-package
	$(RM) -r rpm-package

deb:
	cd debian-package/ && dpkg-buildpackage -rfakeroot -us -uc -b

rpm: vcs.spec
	mkdir rpm-package/vcs-$(VER)/
	cp vcs CHANGELOG rpm-package/Makefile rpm-package/vcs-$(VER)/
	mv vcs.spec rpm-package/vcs-$(VER)/
	cd rpm-package && tar zcvf vcs-$(VER).tar.gz vcs-$(VER)
	$(RM) vcs.spec
	$(RM) -r rpm-package/vcs-$(VER)
	cd rpm-package && fakeroot rpmbuild -tb vcs-$(VER).tar.gz
	$(RM) rpm-package/vcs-$(VER).tar.gz

vcs.spec: rpm-package/vcs.spec.in
	cd rpm-package && $(MAKE) -f Makefile spec PACKAGER="$(PACKAGER)"
	mv rpm-package/vcs.spec .

.PHONY: dist
