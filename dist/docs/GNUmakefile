#
# $Id$
#
# This Makefile uses GNU Make syntax.
# The distribution tarball should already include the files generated
# here so there's usually no need to use it.
#

distdir:=.
srcdir=src

ALL=$(addprefix $(distdir)/,vcs.1 vcs.conf.5 \
		$(addprefix vcs.man,.html .xhtml .pdf) \
		$(addprefix vcs.conf.man,.html .xhtml .pdf) \
	)
INTERMEDIATE=$(addprefix $(srcdir)/, \
			 	$(addsuffix .tex, vcs.man vcs.conf.man) \
			)

ifeq ($(shell uname),FreeBSD)
DOCBOOK_XSL:=/usr/local/share/xsl/docbook
endif
# Used to be "jade".
# On Debian Sid openjade and jadetex (for pdfjadetex) are required
JADE:=openjade
DOCBOOK_XSL?=/usr/share/xml/docbook/stylesheet/docbook-xsl
# Common part of command to convert docbook to man
DOCBOOK_TO_MAN=xsltproc -o $(distdir)/ -nonet \
		--xinclude \
		-param man.charmap.use.subset "0" \
		-param make.year.ranges "1" \
		-param make.single.year.ranges "1" \
		$(DOCBOOK_XSL)/manpages/docbook.xsl

all: $(ALL)

clean:
	$(RM) $(ALL) $(INTERMEDIATE)

# man2html produces output closer to man and better formatted but
# easily broken while xsltproc produces cleaner, more robust, and
# cross-referenced output

# sed post processing:
#  add CSS link
#  obfuscate mailto: links
#  obfuscate emails
$(distdir)/vcs.%.xhtml: $(srcdir)/vcs.%.xml
	xsltproc -nonet \
		--xinclude \
		-param man.charmap.use.subset "0" \
		-param make.year.ranges "1" \
		-param make.single.year.ranges "1" \
		$(DOCBOOK_XSL)/xhtml/docbook.xsl \
		"$<" > "$@" || ( $(RM) "$@" && false )
	sed -i \
		-e 's!</head>!<link rel="stylesheet" type="text/css" href="man.css"/></head>!' \
		-e 's/mailto:\([[:alnum:]]*\)@\([[:alnum:]]*\)\.\([[:alpha:]]*\)/mailto:\1%40\2%2E\3/' \
		-e 's/\([[:alnum:]]*\)@\([[:alnum:]]*\)\.\([[:alpha:]]*\)/\1\&#64;\2\&#x2e;\3/' \
		"$@"

# The xml.dcl file MUST be included in this order, after options and before inputs
$(srcdir)/vcs.conf.man.tex: $(srcdir)/vcs.conf.man.xml
	cd $(srcdir) && bash flatten_settings_xml.bash > temp.xml || ( rm temp.xml && false )
	"$(JADE)" -E0 -t tex \
			-d /usr/share/sgml/docbook/stylesheet/dsssl/modular/print/docbook.dsl \
			-o "$@" \
			/usr/share/sgml/declaration/xml.dcl \
			$(srcdir)/temp.xml || ( rm $(srcdir)/temp.xml && false )
	$(RM) $(srcdir)/temp.xml

$(srcdir)/vcs.man.tex: $(srcdir)/vcs.man.xml
	"$(JADE)" -E0 -t tex \
		-d /usr/share/sgml/docbook/stylesheet/dsssl/modular/print/docbook.dsl \
		-o "$@" \
		/usr/share/sgml/declaration/xml.dcl \
		"$<" >/dev/null

$(distdir)/vcs.%.pdf: $(srcdir)/vcs.%.tex
	pdfjadetex -output-directory $(distdir) $<
	$(RM) $(addprefix $(distdir)/vcs.$(*), .log .aux .out)

# Check all XML files for validity
lint:
	# XML check
	find . -type f -name '*.xml' -print0 | \
			xargs -0 xmllint -nonet --xinclude -noout --valid
	# XHTML check
	# Use `$(MAKE) xhtml' before running `$(MAKE) $@' to
	#  actually validate XHTML
	find . -type f -name '*.xhtml' -exec bash -c "echo '[ {} ]' && tidy -utf8 -eq '{}'" \;

xhtml: $(filter %.xhtml, $(ALL))

$(distdir)/vcs.man.html: $(distdir)/vcs.1
	man2html -r "$<" > "$@"

$(distdir)/vcs.conf.man.html: $(distdir)/vcs.conf.5
	man2html -r "$<" > "$@"

$(distdir)/vcs.1: $(srcdir)/vcs.man.xml
	#xmlto -o `dirname $@`/ man $< 
	$(DOCBOOK_TO_MAN) "$<"

$(distdir)/vcs.conf.5: $(srcdir)/vcs.conf.man.xml
	$(DOCBOOK_TO_MAN) "$<"

.PHONY: all clean lint xhtml
