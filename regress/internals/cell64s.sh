#!/bin/ksh

. ../../kbf.sh

init

echo -n "underflow 1 : 0 - 1 = "
$array tape 0
cell64s -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 9223372036854775807 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 2 : 0 - 1 - 1 = "
$array tape 0
cell64s -1
cell64s -1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 9223372036854775806 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "underflow 3 : 0 - 2 = "
$array tape 0
cell64s -2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 9223372036854775806 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 1 : 9223372036854775807 + 1 = "
$array tape 9223372036854775807
cell64s 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 0 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 2 : 9223372036854775807 + 1 + 1 = "
$array tape 9223372036854775807
cell64s 1
cell64s 1
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

echo -n "overflow 3 : 9223372036854775807 + 2 = "
$array tape 9223372036854775807
cell64s 2
echo -n "${tape[$tptr]} -> "
if [ ${tape[$tptr]} -eq 1 ]; then
	echo "OK"
else
	echo "KO"
fi

