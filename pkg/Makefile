# $Id$

prefix:=/usr/local
DESTDIR:=/
VERSION:=$(shell head -50 vcs | grep 'declare -r VERSION=' | perl -pe 's/.*"(.*)".*/\1/')
PACKAGER:=$(shell echo $$DEBFULLNAME)
ifeq ($(PACKAGER),)
  PACKAGER:=$(shell finger -lp `echo $USER` 2>/dev/null | head -n1 | cut -d: -f3)
endif
ifeq ($(PACKAGER),)
  PACKAGER:=$(shell grep ^`id -un` /etc/passwd | cut -d: -f5 | cut -d, -f1)
endif

all: vcs.spec

install:
	install -D -m755 vcs $(DESTDIR)$(prefix)/bin/vcs

uninstall:
	$(RM) $(DESTDIR)$(prefix)/bin/vcs
	-rmdir -p $(DESTDIR)$(prefix)/bin

vcs.spec: rpm/vcs.spec.in
	test -f vcs -a "$(VERSION)" # Version (=$(VERSION)) must be detected
	@echo "[vcs.spec]"
	@cat $< | sed 's!@VERSION@!$(VERSION)!g' | \
		sed 's!@PACKAGER@!$(PACKAGER)!g' > $@

PKGBUILD: arch/PKGBUILD.in
	test -f vcs -a "$(VERSION)" # Version (=$(VERSION)) must be detected
	@echo "[PKGBUILD]"
	@cat $< | sed -e 's!@VERSION@!$(VERSION)!g' \
		-e 's!@MD5@!'\''$(shell bzip2 -c9 < vcs | md5sum -b - | cut -d' ' -f1)'\''!g' \
		-e 's!@SHA1@!'\''$(shell bzip2 -c9 < vcs | sha1sum -b - | cut -d' ' -f1)'\''!g' > $@

clean:
	-$(RM) vcs.spec PKGBUILD

.PHONY: all install clean
