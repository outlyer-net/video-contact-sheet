#!/usr/bin/make -f
# $Id$

srcdir=pkg
VER=$(shell grep VERSION $(srcdir)/vcs | head -n1 | sed 's/\#.*//' | sed -r 's/.*"(.*)".*/\1/g')

all: pkg/vcs.1 pkg/manpage.html pkg/manpage.xhtml
	@echo "Use $(MAKE) dist"

pkg/vcs.1: src/manpage.vcs.xml
	if type -p xmlto >/dev/null ; then \
		xmlto -o `dirname $@`/ man $< ; \
	else \
		xsltproc -o `dirname $@`/ -''-nonet \
			-''-param man.charmap.use.subset "0" \
			-''-param make.year.ranges "1" \
			-''-param make.single.year.ranges "1" \
			/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl \
			$<; \
	fi

# man2html produces output closer to man and better formatted but
# easily broken while xsltproc produces cleaner, more robust, and
# cross-referenced output
pkg/manpage.html: pkg/vcs.1
	man2html -r $< > $@

pkg/manpage.xhtml: src/manpage.vcs.xml
	xsltproc \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml/docbook.xsl \
		$< > $@

pkg/vcs.conf.5: src/manpage.vcs.conf.xml
	xsltproc -o `dirname $@`/ -''-nonet \
			-''-param man.charmap.use.subset "0" \
			-''-param make.year.ranges "1" \
			-''-param make.single.year.ranges "1" \
			/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl \
			$<; \

pkg/vcs.conf.xhtml: src/manpage.vcs.conf.xml
	xsltproc \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml/docbook.xsl \
		$< > $@

tgz: vcs-$(VER).tar.gz

vcs-$(VER).tar.gz:
	cp -rvpP pkg/ vcs-$(VER)
	cd vcs-$(VER) && make dist
	tar zcvf vcs-$(VER).tar.gz --exclude '.svn' --exclude '*.swp' --exclude '*.swo' vcs-$(VER)
	$(RM) -r vcs-$(VER)

check-no-svn:
	@if [ -d .svn ]; then \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
		echo "**     Don't release from SVN working copy     **" ; \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
	fi

check-rel:
	@if head -n50 vcs | grep -q 'RELEASE=0' ; then \
		echo 'RELEASE is set to 0!' ; false ; fi

dist: check-rel check-no-svn \
		pkg/vcs.1 \
		pkg/manpage.html \
		vcs-$(VER).tar.gz \
		PKGBUILD-$(VER) \
		vcs-$(VER).gz vcs-$(VER).bz2 vcs-$(VER).bash \
		CHANGELOG.gz CHANGELOG \
		rpm deb

PKGBUILD-$(VER): vcs-$(VER).tar.gz
	cd pkg && ln -s ../vcs-$(VER).tar.gz ./
	cd pkg && make PKGBUILD
	$(RM) pkg/vcs-$(VER).tar.gz
	mv pkg/PKGBUILD $@

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
