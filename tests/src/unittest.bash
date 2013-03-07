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
	res=$($fn $args)
	ret=$?
	passed=
	if [[ $expected == '><' ]]; then # Expected to fail
		if [[ $ret != 0 ]]; then
			passed=1
		else
			passed=0
		fi
	elif [[ $res != $expected ]] && ( [[ $res ]] && ! fptest "$res" ~ "$expected" ) ; then
		passed=0
	else
		passed=1
	fi

	if [[ $passed -ne 1 ]]; then
		echo -n "${R}FAILED	=> $res != '$expected'"
		let 'RET++'
	else
		echo -n "${G}PASSED => $res ~= $expected"
	fi
	echo $CLR
}

