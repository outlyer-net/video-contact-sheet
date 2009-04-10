#!/usr/bin/make -f
# $Id$

VER=$(shell grep VERSION vcs|head -n1|sed 's/#.*//'|sed -r 's/.*"(.*)".*/\1/g')

all:
	@echo "Use $(MAKE) dist"

check-no-svn:
	if [ -d .svn ]; then echo "Don't release from SVN working copy" ; false ; fi

prep:
	cp vcs CHANGELOG debian-package/
	chmod -x vcs

dist: check-no-svn prep gz bz2 plaintext changelog deb cleanup

gz:
	cp vcs vcs-$(VER)
	gzip -9 vcs-$(VER)

bz2:
	cp vcs vcs-$(VER)
	bzip2 -9 vcs-$(VER)

plaintext:
	mv vcs vcs-$(VER)

changelog:
	gzip -9 CHANGELOG
	gzip -dc CHANGELOG.gz > CHANGELOG

cleanup:
	$(RM) -i Makefile *.changes
	$(RM) -r debian-package

deb:
	cd debian-package/ && dpkg-buildpackage -rfakeroot -us -uc -b


.PHONY: dist
