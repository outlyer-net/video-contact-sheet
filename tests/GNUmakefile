# $Id$

VCS:=../vcs
extract=sed -n "/$*()"'/,/^}$$/p' "$(VCS)"


all: get_interval

constants.inc.bash:
	sed -n '/{{{ # Constants/,/}}}/p' "$(VCS)" > $@

get_interval: $(addsuffix .func.bash,get_interval trace error is_number tolower) \
			 $(addsuffix .inc.bash,constants)
	{ \
		echo '#!/bin/bash' ; \
		for req in $^; do \
			echo "source $$req" ; \
		done ; \
	}
%.func.bash:
	$(extract) >$@

clean:
	$(RM) *.func.bash *.inc.bash

