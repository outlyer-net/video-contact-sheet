#!/bin/bash

SETTINGS_XML=vcs.conf.man.xml

IN=0
while read line ; do
	if grep -q '<xi:include' <<<"$line" ; then
		IN=1
	elif [[ $IN -eq 1 ]]; then
		if grep -q 'href=' <<<"$line" ; then
			toinclude=$(sed -r 's/.*href="([^"]*)".*/\1/'<<<"$line")
			docstart=$(egrep -n '^]>$' $toinclude | cut -d':' -f1)
			let 'docstart++'
			sed -n "$docstart,\$p" "$toinclude"
		fi
	fi
	if [[ $IN -ne 1 ]]; then
		echo "$line"
	fi
	if [[ $IN -eq 1 ]] && grep -q '/>' <<<"$line"; then
		IN=0
	fi
done < ${SETTINGS_XML}

