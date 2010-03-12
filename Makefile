#!/usr/bin/make -f
# $Id$

srcdir=pkg
VER=$(shell grep VERSION $(srcdir)/vcs | head -n1 | sed 's/\#.*//' | sed -r 's/.*"(.*)".*/\1/g')

all:
	@echo "Use $(MAKE) dist"

vcs-$(VER).tar.gz:
	cp -rvpP pkg/ vcs-$(VER)
	cd vcs-$(VER) && make dist
	tar zcvf vcs-$(VER).tar.gz --exclude '.svn' --exclude '*.swp' --exclude '*.swo' vcs-$(VER)
	$(RM) -r vcs-$(VER)

check-no-svn:
	#@if [ -d .svn ]; then echo "Don't release from SVN working copy" ; false ; fi

check-rel:
	@if head -n50 vcs | grep -q 'RELEASE=0' ; then \
		echo 'RELEASE is set to 0!' ; false ; fi

dist: check-rel check-no-svn \
		vcs-$(VER).tar.gz \
		vcs-$(VER).gz vcs-$(VER).bz2 vcs-$(VER).bash \
		CHANGELOG.gz CHANGELOG \
		rpm deb

vcs-$(VER).gz: $(srcdir)/vcs
	gzip -c9 < vcs > $@

vcs-$(VER).bz2: $(srcdir)/vcs
	bzip2 -c9 < vcs > $@

vcs-$(VER).bash: $(srcdir)/vcs
	cat $< > $@

CHANGELOG.gz: $(srcdir)/CHANGELOG
	gzip -c9 < $< > $@

CHANGELOG: $(srcdir)/CHANGELOG
	cp $< $@

distclean:
	$(RM) -ri vcs Makefile *.changes pkg

deb:
	cd pkg && debuild -us -uc -b && debclean
	$(RM) vcs_*.changes vcs_*.build

rpm: vcs-$(VER).tar.gz
	rpmbuild --clean -tb vcs-$(VER).tar.gz
	test -d ~/rpmbuild/RPMS/noarch && ln -s ~/rpmbuild/RPMS/noarch/vcs-$(VER)-*.rpm . || true
	test -d ~/RPM/RPMS/noarch && ln -s ~/RPM/RPMS/noarch/vcs-$(VER)-*.rpm . || true

clean:
	-$(RM) vcs[-_]$(VER)* CHANGELOG*

.PHONY: dist
