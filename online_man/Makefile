#
# $Id$
#

docsdir=../dist/docs

all: man.vcs.html

man.vcs.html: $(docsdir)/vcs.man.html
	cp $< $@

$(docsdir)/%:
	make -C $(docsdir) $*

clean:
	$(RM) man.vcs.html man.vcs.conf.html

.PHONY: all clean
