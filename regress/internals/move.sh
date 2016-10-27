#!/bin/ksh

. ../../kbf.sh as a library
init
$array tape 0 1 2 3 4 5 6 7 8 9

echo "TAP version 13"
echo "1..4"

title="move 5 cells to the right"
move 5
if [ ${tape[$tptr]} -eq 5 ]; then
	echo "ok 1 - $title"
else
	echo "not ok 1 - $title"
fi

title="move 2 cells to the left"
move -2
if [ ${tape[$tptr]} -eq 3 ]; then
	echo "ok 2 - $title"
else
	echo "not ok 2 - $title"
fi

title="move 3 cells to the left"
move -3
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "ok 3 - $title"
else
	echo "not ok 3 - $title"
fi

title="move bellow zero (this should fail !)"
if $(move -1 2> /dev/null); then
	echo "not ok 4 - $title"
else
	echo "ok 4 - $title"
fi

