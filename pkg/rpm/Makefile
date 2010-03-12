# $Id$

prefix:=/usr
DESTDIR:=/
VERSION:=$(shell head -50 vcs | grep 'declare -r VERSION=' | perl -pe 's/.*"(.*)".*/\1/')
#PACKAGER=$(shell grep ^`id -nu` /etc/passwd | cut -d: -f5 | cut -d, -f1)

all:
	@echo 'There'\''s nothing to be built'
	@echo 'Available make commands:'
	@echo '* Build RPM (and generate spec)'
	@echo '  $$ make rpm'
	@echo '* Generate spec file'
	@echo '  $$ make spec'
	@echo '* Install'
	@echo '  $$ make install'

clean:
	$(RM) vcs.spec

spec: vcs.spec.in
	test "$(VERSION)"
	@test "$(PACKAGER)" || echo "No PACKAGER set!"
	@test "$(PACKAGER)"
	cat vcs.spec.in | sed 's!@VERSION@!$(VERSION)!g' | \
			  sed 's!@PACKAGER@!$(PACKAGER)!g' > vcs.spec

install:
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -m755 -o0 -g0 vcs $(DESTDIR)$(prefix)/bin


.PHONY: all install clean spec
