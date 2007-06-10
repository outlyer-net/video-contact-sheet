#!/usr/bin/make -f

VER=$(shell grep VERSION vcs|head -n1|sed -r 's/.*"(.*)".*/\1/g')

all:
	@echo "Use $(MAKE) dist"

dist:
	if [ -d .svn ]; then echo "Don't release from SVN working copy" ; false ; fi
	cp vcs vcs-$(VER)
	gzip -9 vcs-$(VER)
	cp vcs vcs-$(VER)
	bzip2 -9 vcs-$(VER)
	mv vcs vcs-$(VER)
	gzip -9 CHANGELOG
	gzip -dc CHANGELOG.gz > CHANGELOG
	rm -i Makefile

.PHONY: dist
