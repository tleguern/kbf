#!/bin/ksh

. ../../kbf.sh as a library

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell24 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 16777215 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell24 -1
cell24 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 16777214 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell24 -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 16777214 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 16777215 + 1 = "
$array tape 16777215
cell24 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 16777215 + 1 + 1 = "
$array tape 16777215
cell24 1
cell24 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 16777215 + 2 = "
$array tape 16777215
cell24 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

