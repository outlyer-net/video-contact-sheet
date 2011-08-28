#
# $Id$
# Makefile for GNU-make
#

VERSION:=$(shell sed -n '/VERSION=/s/.*"\([^"]*\)".*/\1/p' vcs)
PACKAGER:=$(shell finger -lp `echo $USER` 2>/dev/null | head -n1 | cut -d: -f3)
ifeq ($(PACKAGER),)
  PACKAGER:=$(shell getent passwd "`id -un`" | cut -d: -f5 | cut -d, -f1)
endif

include common.mk

