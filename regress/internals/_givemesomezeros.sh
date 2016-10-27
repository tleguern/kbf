#!/bin/ksh

cd $(dirname $0)
. ../../kbf.sh as a library
init
$array tape 0 1 2 3 4 5 6 7 8 9

echo "TAP version 13"
echo "1..3"

title="Generate 10 zeros"
if [ $(_givemesomezeros 10 | wc -l) -eq 10 ]; then
	echo "ok 1 - $title"
else
	echo "not ok 1 - $title"
fi

title="Generate 1 zeros"
if [ $(_givemesomezeros 1 | wc -l) -eq 1 ]; then
	echo "ok 2 - $title"
else
	echo "not ok 2 - $title"
fi

title="Generate 0 zeros"
if [ $(_givemesomezeros 0 | wc -l) -eq 0 ]; then
	echo "ok 3 - $title"
else
	echo "not ok 3 - $title"
fi

