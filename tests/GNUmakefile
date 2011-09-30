# $Id$

VCS:=../vcs
#VCS:=../portability/oldvcs/vcs-1.11.2
extract=sed -n "/^$*()"'/,/^}$$/p' "$(VCS)"


TESTS_FILE=src/tests.txt
TEST_MAKER=src/make_test.bash
get_interval_reqs = $(addprefix inc/, \
						$(addsuffix .func.bash,get_interval trace error \
								is_number tolower assert awkexf fptest \
								fsimeq notice) \
				 		$(addsuffix .inc.bash,constants) \
					)

all: get_interval

inc/constants.inc.bash: $(VCS)
	mkdir -p inc/
	echo 'declare -r RELEASE=0' > $@
	echo 'declare DEBUG=1' >> $@
	echo '$(shell grep -m1 'VERSION=' "$(VCS)")' >> $@
	sed -n '/{{{ # Constants/,/}}}/p' "$(VCS)" >> $@

get_interval: $(TESTS_FILE) $(get_interval_reqs)
	$(TEST_MAKER) $@ $(get_interval_reqs) > $@.test.bash
	chmod +x $@.test.bash

inc/%.func.bash: $(VCS)
	mkdir -p inc
	$(extract) >$@

clean:
	$(RM) inc/* *.test.bash
	-rmdir -p inc/

