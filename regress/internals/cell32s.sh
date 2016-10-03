#!/bin/ksh

. ../../kbf.sh as a library

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell32s -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 2147483647 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell32s -1
cell32s -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 2147483646 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell32s -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 2147483646 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 2147483647 + 1 = "
$array tape 2147483647
cell32s 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 2147483647 + 1 + 1 = "
$array tape 2147483647
cell32s 1
cell32s 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 2147483647 + 2 = "
$array tape 2147483647
cell32s 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

