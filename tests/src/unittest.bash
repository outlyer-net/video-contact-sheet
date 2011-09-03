#
# $Id$
# Receives the raw input as found in tests.txt
#

TESTNUM=0

G=$(tput setaf 2 ; tput bold )
R=$(tput setaf 1 ; tput bold)
CLR=$(tput sgr0)

RET=0

function unittest {
	let 'TESTNUM++'
	a="$@"
	fn=$(cut -d' ' -f1 <<<"$a")
	if [[ $TESTNUM -eq 1 ]]; then
		type $fn
	fi
	args=$(cut -d' ' -f2- <<<"$a" | sed 's/:.*$//' | sed 's/ *$//')
	expected=$(cut -d' ' -f2- <<<"$a" | sed 's/.*://')
	echo "$fn($args) -> $expected" >&2
	ret=$($fn $args)
	RET=$[ $RET + $?]
	if [[ $ret != $expected ]] && ! fptest "$ret" ~ "$expected" ; then
		echo -n "${R}FAILED	=> $ret != '$expected'"
	else
		echo -n "${G}PASSED => $ret ~= $expected"
	fi
	echo $CLR
}

