#!/bin/ksh

. ../../kbf.sh as a library

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell16 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 65535 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell16 -1
cell16 -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 65534 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell16 -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 65534 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 65535 + 1 = "
$array tape 65535
cell16 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 65535 + 1 + 1 = "
$array tape 65535
cell16 1
cell16 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 65535 + 2 = "
$array tape 65535
cell16 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

