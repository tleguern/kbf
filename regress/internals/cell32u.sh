#!/bin/ksh

. ../../kbf.sh as a library

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell32u -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 4294967295 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell32u -1
cell32u -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 4294967294 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell32u -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 4294967294 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 4294967295 + 1 = "
$array tape 4294967295
cell32u 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 4294967295 + 1 + 1 = "
$array tape 4294967295
cell32u 1
cell32u 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 4294967295 + 2 = "
$array tape 4294967295
cell32u 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

