#!/usr/bin/make -f

VER=$(shell grep VERSION vcs|head -n1|sed -r 's/.*"(.*)".*/\1/g')

all:
	@echo "Use $(MAKE) dist"

check-no-svn:
	if [ -d .svn ]; then echo "Don't release from SVN working copy" ; false ; fi

prep:
	chmod -x vcs

dist: check-no-svn prep gz bz2 plaintext changelog cleanup

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
	rm -i Makefile

deb:


.PHONY: dist
