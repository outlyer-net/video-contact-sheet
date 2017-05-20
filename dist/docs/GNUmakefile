#
# $Id$
#
# This Makefile uses GNU Make syntax.
# The distribution tarball should already include the files generated
# here so there's usually no need to use it.
#

distdir:=.
srcdir=src

# Since 1.13.3 the man pages are combined into a single input
# The XHTML output contains both man pages as a side effect, while the groff
# and PDF output are separate for each man page. TeX output was removed from
# this makefile.
DEFAULT=$(addprefix $(distdir)/,vcs.1 vcs.conf.5 \
		$(addprefix vcs.man,.html .pdf) \
		$(addprefix vcs.conf.man,.pdf) \
	)
EXTRA=$(addprefix $(distdir)/,vcs.man2html.html vcs.conf.man2html.html)
ALL=$(DEFAULT) $(EXTRA)

ifeq ($(shell uname),FreeBSD)
DOCBOOK_XSL:=/usr/local/share/xsl/docbook
endif
DOCBOOK_XSL?=/usr/share/xml/docbook/stylesheet/docbook-xsl
# Common part of command to convert docbook to man
DOCBOOK_TO_COMMON=xsltproc -nonet \
		--xinclude \
		-param man.charmap.use.subset "0" \
		-param make.year.ranges "1" \
		-param make.single.year.ranges "1"
# NOT: For manpages the output can be a directory, whereas for XHTML it can not
DOCBOOK_TO_MAN=$(DOCBOOK_TO_COMMON) -o $(distdir)/ $(DOCBOOK_XSL)/manpages/docbook.xsl
DOCBOOK_TO_XHTML=$(DOCBOOK_TO_COMMON) $(DOCBOOK_XSL)/xhtml/docbook.xsl

default: $(DEFAULT)
extra: $(EXTRA)
all: $(ALL)

env:
	@echo --- Values of Makefile variables: ---
	@echo DEFAULT: $(DEFAULT)
	@echo EXTRA: $(EXTRA)
	@echo ALL: $(ALL)
	@echo INTERMEDIATE: $(INTERMEDIATE)
	@echo DOCBOOK_XSL: $(DOCBOOK_XSL)
	@echo DOCBOOK_TO_MAN: $$ $(DOCBOOK_TO_MAN)
	@echo DOCBOOK_TO_XHTML: $$ $(DOCBOOK_TO_XHTML)
	@echo distdir: $(distdir)
	@echo srcdir: $(srcdir)
	@echo -------------------------------------

clean:
	$(RM) $(ALL) $(INTERMEDIATE)

# These are both generated at once
$(distdir)/vcs.1 $(distdir)/vcs.conf.5: $(srcdir)/vcs.man.xml
	#xmlto -o `dirname $@`/ man $< 
	$(DOCBOOK_TO_MAN) "$<"

# man2html produces output closer to man and better formatted but
# easily broken while xsltproc produces cleaner, more robust, and
# cross-referenced output

# Note with both manpages combined the output is combined too
$(distdir)/vcs.man.html: $(srcdir)/vcs.man.xml
	$(DOCBOOK_TO_XHTML) "$<" > "$@" || ( $(RM) "$@" && false )
	@# sed post processing:
	@#  add CSS link
	@#  obfuscate mailto: links
	@#  obfuscate emails
	@#  replace groff-escaped dots ("\[char46]")
	sed -i \
		-e 's!</head>!<link rel="stylesheet" type="text/css" href="man.css"/></head>!' \
		-e 's/mailto:\([[:alnum:]]*\)@\([[:alnum:]]*\)\.\([[:alpha:]]*\)/mailto:\1%40\2%2E\3/' \
		-e 's/\([[:alnum:]]*\)@\([[:alnum:]]*\)\.\([[:alpha:]]*\)/\1\&#64;\2\&#x2e;\3/' \
		-e 's/\\\[char46\]/./g' \
		"$@"
	@# man2html includes the last revision date, which xsltproc does not, it
	@# seems useful to me, so I'm injecting it here
	sed -i \
		-e 's!</h1>!</h1>$(shell grep 'Last revision' $< | head -1 \
						| sed   -e 's!.*<date>!!' \
								-e 's!</date>.*$$!!')!' \
		"$@"

#####
##### RULES SHARING RECIPES
##### See http://stackoverflow.com/questions/11441084/makefile-with-multiples-rules-sharing-same-recipe
#####

# 1/2: Pre-requisites
$(distdir)/vcs.conf.man.pdf: $(distdir)/vcs.conf.5.pdf
$(distdir)/vcs.man.pdf: $(distdir)/vcs.1.pdf
$(distdir)/vcs.man2html.html: $(distdir)/vcs.1
$(distdir)/vcs.conf.man2html.html: $(distdir)/vcs.conf.5

# 2/2: Common recipe
$(distdir)/vcs.conf.man.pdf $(distdir)/vcs.man.pdf:
	mv $< $@

#####
##### / END OF RULES SHARING RECIPES
#####

$(distdir)/vcs.man2html.html $(distdir)/vcs.conf.man2html.html:
	@# The first two lines of man2html are HTTP headers
	@# The manpage is preprocessed to replace groff-escaped dots (\[char46])
	sed -e 's/\\\[char46\]/\\./g' "$<" | man2html -r | sed 1,2d > "$@"

# jade and docbook-to-man conversions don't appear to agree on what's the
# correct structure, to avoid this here I use doclifter to convert back from
# man to DocBook, which generates a less semantically-rich but easier to
# process DocBook file
$(distdir)/vcs.%.pdf: vcs.%
	doclifter < $< > temp.xml || ( $(RM) temp.xml && false )
	db2pdf temp.xml || ( $(RM) temp.xml && false )
	-$(RM) temp.xml
	mv temp.pdf $@

# Check all XML files for validity
lint:
	# XML check
	find . -type f -name '*.xml' -print0 | \
			xargs -0 xmllint -nonet --xinclude -noout --valid
	# XHTML check
	# Use `$(MAKE) xhtml' before running `$(MAKE) $@' to
	#  actually validate XHTML
	find . -type f -name '*.html' -exec bash -c "echo '[ {} ]' && tidy -utf8 -eq '{}'" \;

xhtml: $(filter %.html, $(DEFAULT))

.PHONY: all default extra env clean lint xhtml
