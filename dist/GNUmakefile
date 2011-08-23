#
# $Id$
# Makefile for GNU-make
#

VERSION:=$(shell head -50 vcs | grep 'declare -r VERSION=' | sed -e 's/.*"\(.*\)".*/\1/')
PACKAGER:=$(shell finger -lp `echo $USER` 2>/dev/null | head -n1 | cut -d: -f3)
ifeq ($(PACKAGER),)
  PACKAGER:=$(shell grep ^`id -un` /etc/passwd | cut -d: -f5 | cut -d, -f1)
endif

include common.mk

