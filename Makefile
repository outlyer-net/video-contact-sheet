#!/usr/bin/make -f
# $Id$

srcdir=dist
VER=$(shell grep VERSION $(srcdir)/vcs | head -n1 | sed 's/\#.*//' | sed -r 's/.*"(.*)".*/\1/g')

ALL=$(addprefix $(srcdir)/,vcs.1 vcs.conf.5 \
		$(addprefix vcs.man,.html .xhtml) \
		$(addprefix vcs.conf.man,.html .xhtml) \
	)
# Common part of command to convert docbook to man
DOCBOOK_TO_MAN=xsltproc -o $(srcdir)/ -nonet \
		--xinclude \
		-param man.charmap.use.subset "0" \
		-param make.year.ranges "1" \
		-param make.single.year.ranges "1" \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl

all: $(ALL)
	@echo "Use $(MAKE) dist to create the actual distribution files"

# man2html produces output closer to man and better formatted but
# easily broken while xsltproc produces cleaner, more robust, and
# cross-referenced output
$(srcdir)/vcs.%.xhtml: $(srcdir)/vcs.%.xml
	xsltproc -nonet \
		--xinclude \
		-param man.charmap.use.subset "0" \
		-param make.year.ranges "1" \
		-param make.single.year.ranges "1" \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml/docbook.xsl \
		"$<" > "$@"
	sed -i \
		's!</head>!<link rel="stylesheet" type="text/css" href="man.css"/></head>!' \
		"$@"

# Check all XML files for validity
xmllint:
	find . -type f -name '*.xml' -print0 | xargs -0 xmllint --xinclude -noout --valid

$(srcdir)/vcs.man.html: $(srcdir)/vcs.1
	man2html -r "$<" > "$@"

$(srcdir)/vcs.conf.man.html: $(srcdir)/vcs.conf.5
	man2html -r "$<" > "$@"

$(srcdir)/vcs.1: $(srcdir)/vcs.man.xml
	#xmlto -o `dirname $@`/ man $< 
	$(DOCBOOK_TO_MAN) "$<"

$(srcdir)/vcs.conf.5: $(srcdir)/vcs.conf.man.xml
	$(DOCBOOK_TO_MAN) "$<"


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

# This shouldn't be re-built
dist/mansrc/settings.man.inc.xml:
	cd dist/mansrc && $(MAKE)

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
	-$(RM) vcs[-_]$(VER)* CHANGELOG* $(ALL)

.PHONY: dist
