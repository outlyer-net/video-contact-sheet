# $Id$
#
# To be included from GNUmakefile or BSDmakefile
# To use it directly set VERSION and PACKAGER
# e.g. make VERSION=1.x PACKAGER=Me <rule>
#
# Notes to self:
# This file should follow only common/portable make syntax and commands
# Common pitfalls:
#   - $(shell) -> GNU Make, equivalent BSD make: !=
#   - install -D -> GNU only (-d is portable)
#   - $(RM) -> empty by default in BSD, set from BSDmakefile

prefix:=/usr/local
DESTDIR:=/
TGZ=vcs-$(VERSION).tar.gz

MANDIR:=$(prefix)/share/man

all: docs/vcs.1 docs/vcs.conf.5 vcs.spec
	#
	# Automatically detected value:
	#   PACKAGER=$(PACKAGER)
	# To set it manually add it to Make's command-line like:
	#  $$ $(MAKE) PACKAGER="This Is My Name"

dist: vcs-$(VERSION).tar.gz

vcs-$(VERSION).tar.gz: all
	$(RM) -r vcs-$(VERSION) vcs-$(VERSION).tar.gz
	mkdir vcs-$(VERSION)
	tar c --exclude='.svn' \
			--exclude='*.swp' --exclude='*.swo' \
			--exclude='vcs-$(VERSION)' . |\
		tar x -C vcs-$(VERSION)
	tar zcf vcs-$(VERSION).tar.gz vcs-$(VERSION)/
	$(RM) -r vcs-$(VERSION)

docs/vcs.1 docs/vcs.conf.5:
	$(GMAKE) -C docs `basename $@`

# Files installed in packages
prepackage: examples/vcs.conf.example

install:
	install -d $(DESTDIR)$(prefix)/bin/
	install -m755 vcs $(DESTDIR)$(prefix)/bin/vcs
	install -d $(DESTDIR)$(prefix)/share/vcs/profiles
	install -m644 profiles/*.conf $(DESTDIR)$(prefix)/share/vcs/profiles/
	install -d $(DESTDIR)$(MANDIR)/man1/ $(DESTDIR)$(MANDIR)/man5/
	install -m644 docs/vcs.1 $(DESTDIR)$(MANDIR)/man1/
	install -m644 docs/vcs.conf.5 $(DESTDIR)$(MANDIR)/man5/

uninstall:
	$(RM) $(DESTDIR)$(prefix)/bin/vcs
	$(RM) $(DESTDIR)$(MANDIR)/man1/vcs.1 $(DESTDIR)$(MANDIR)/man5/vcs.conf.5
	for file in profiles/*.conf ; do \
	   $(RM) $(DESTDIR)$(prefix)/share/vcs/profiles/`basename $$file` ; \
	done
	-rmdir -p $(DESTDIR)$(prefix)/bin
	-rmdir -p $(DESTDIR)$(prefix)/share/vcs/profiles
	-rmdir -p $(DESTDIR)$(MANDIR)/man1 $(DESTDIR)$(MANDIR)/man5

examples/vcs.conf.example: docs/src/vcs.conf.example
	sed -e 's/^/#/;s/^#$$//;s/^##/#/' < $< > $@

vcs.spec: rpm/vcs.spec.in vcs
	test "$(VERSION)" # Version (=$(VERSION)) must be defined
	@echo "[creating vcs.spec]"
	@cat $< | sed 's!@VERSION@!$(VERSION)!g' | \
		sed 's!@PACKAGER@!$(PACKAGER)!g' > $@

# PKGBUILD CAN'T BE INCLUDED in the archive
PKGBUILD: arch/PKGBUILD.in $(TGZ) vcs
	test "$(VERSION)" # Version (=$(VERSION)) must be detected
	@echo "[PKGBUILD]"
	@MD5=$(shell md5sum -b $(TGZ) | cut -d' ' -f1) ; \
		SHA1=$(shell sha1sum -b $(TGZ) | cut -d' ' -f1) ; \
		SHA256=$(shell sha256sum -b $(TGZ) | cut -d' ' -f1) ; \
		cat $< | sed -e 's!@VERSION@!$(VERSION)!g' \
		-e "s/@MD5@/$$MD5/g" \
		-e "s/@SHA1@/$$SHA1/g" -e "s/@SHA256@/$$SHA256/g" > $@

clean:
	#-$(RM) examples/vcs.conf.example
	$(MAKE) -C docs clean

distclean: clean
	-$(RM) vcs.spec PKGBUILD vcs-$(VERSION).tar.gz

.PHONY: all install clean tgz
