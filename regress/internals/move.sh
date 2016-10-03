#!/bin/ksh

. ../../kbf.sh

init
$array tape 0 1 2 3 4 5 6 7 8 9

echo -n "move 5 cells to the right "
move 5
if [ ${tape[$tptr]} -ne 5 ]; then
	echo "KO"
else
	echo "OK"
fi

echo -n "move 2 cells to the left "
move -2
if [ ${tape[$tptr]} -ne 3 ]; then
	echo "KO"
else
	echo "OK"
fi

echo -n "move 3 cells to the left "
move -3
if [ ${tape[$tptr]} -ne 0 ]; then
	echo "KO"
else
	echo "OK"
fi

echo -n "move 1 cell bellow zero "
if ! $(move -1 > /dev/null 2>&1); then
	echo "not possible - OK"
else
	echo "possible - KO"
fi

