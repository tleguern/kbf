#!/bin/ksh

. ../../kbf.sh

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell8 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 255 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell8 -1
cell8 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 254 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell8 -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 254 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 255 + 1 = "
$array tape 255
cell8 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 255 + 1 + 1 = "
$array tape 255
cell8 1
cell8 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 255 + 2 = "
$array tape 255
cell8 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

