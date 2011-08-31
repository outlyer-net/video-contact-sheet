#
# $Id$
#

srcdir=dist
#VER=$(shell grep VERSION= $(srcdir)/vcs | sed 's/.*"\([^"]*\)".*/\1/')
VER=$(shell sed -n '/VERSION=/s/.*"\([^"]*\)".*/\1/p' $(srcdir)/vcs)

all:
	@echo "-------------------------------------------------------------------------------"
	@echo " Use: "
	@echo "  $$ $(MAKE) dist        # to create the actual v$(VER) distribution files"
	@echo "  $$ $(MAKE) manpages    # to create only the manpages (in $(srcdir)/docs)"
	@echo "  $$ $(MAKE) docs        # to create all documentation formats (in $(srcdir)/docs)"
	@echo
	@echo "  $$ $(MAKE) lint        # to validate documentation sources"
	@echo "  $$ $(MAKE) clean       # to clean generated files"
	@echo "  $$ $(MAKE) distclean   # to clean generated and distribution files"
	@echo "  $$ $(MAKE) uploadclean # to clean non-distribution files"
	@echo "------------------------------------------------------------------------------"

docs: lint
	$(MAKE) -C $(srcdir)/docs all

manpages: lint
	$(MAKE) -C $(srcdir)/docs vcs.1 vcs.conf.5

lint:
	$(MAKE) -C $(srcdir)/docs lint

tgz: vcs-$(VER).tar.gz

vcs-$(VER).tar.gz: $(srcdir)/vcs-$(VER).tar.gz
	mv $< $@

$(srcdir)/vcs-$(VER).tar.gz:
	make -C $(srcdir) distclean `basename $@`

check-no-svn:
	@if [ -d .svn ]; then \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
		echo "**     Don't release from SVN working copy     **" ; \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
		echo ; \
	fi

check-rel:
	@if head -n50 vcs | grep -q 'RELEASE=0' ; then \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
		echo '**           RELEASE is set to 0!              **' ; \
		echo '*************************************************' ; \
		echo '*************************************************' ; \
		echo ; \
	fi

dist: check-rel check-no-svn \
		vcs-$(VER).tar.gz \
		PKGBUILD-$(VER) \
		$(addprefix vcs-$(VER), .gz .bz2 .bash) \
		CHANGELOG.gz CHANGELOG \
		rpm deb

# This shouldn't be re-built
devel_tools/mansrc/settings.man.inc.xml:
	cd `dirname $@` && $(MAKE)

PKGBUILD-$(VER): vcs-$(VER).tar.gz
	cd $(srcdir) && ln -s ../vcs-$(VER).tar.gz ./
	make -C $(srcdir) PKGBUILD
	$(RM) $(srcdir)/vcs-$(VER).tar.gz
	mv $(srcdir)/PKGBUILD $@

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

distclean: clean
	$(RM) PKGBUILD-$(VER) vcs-$(VER).tar.gz $(addprefix vcs-$(VER), .gz .bz2 .bash) \
			CHANGELOG.gz CHANGELOG *.deb *.rpm

# That's the old distclean
uploadclean:
	$(RM) -ri vcs Makefile *.changes pkg

deb:
	cd pkg && debuild -k0x5812006E -us -uc && debclean
	#$(RM) vcs_*.changes vcs_*.build

rpm: vcs-$(VER).tar.gz
	rpmbuild --clean -tb vcs-$(VER).tar.gz
	test -d ~/rpmbuild/RPMS/noarch && ln -s ~/rpmbuild/RPMS/noarch/vcs-$(VER)-*.rpm . || true
	test -d ~/RPM/RPMS/noarch && ln -s ~/RPM/RPMS/noarch/vcs-$(VER)-*.rpm . || true

clean:
	-$(RM) vcs[-_]$(VER)* CHANGELOG*
	make -C $(srcdir)/docs clean

.PHONY: all docs manpages lint clean dist distclean uploadclean \
		check-no-svn check-rel \
		deb rpm tgz
