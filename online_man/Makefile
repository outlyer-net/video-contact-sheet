#
# $Id: Makefile 2317 2011-08-28 03:16:16Z toni $
#

docsdir=../dist/docs

all: man.vcs.html man.vcs.conf.html

man.vcs.html: $(docsdir)/vcs.man.xhtml
	cp $< $@

man.vcs.conf.html: $(docsdir)/vcs.conf.man.xhtml
	cp $< $@

$(docsdir)/%:
	make -C $(docsdir) $*

clean:
	$(RM) man.vcs.html man.vcs.conf.html

