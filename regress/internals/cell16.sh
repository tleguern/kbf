#!/bin/sh

underflow_1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell16 -1
	[ ${tape[$tptr]} -eq 65535 ]
}

underflow_2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell16 -1
	cell16 -1
	[ ${tape[$tptr]} -eq 65534 ]
}

underflow_3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell16 -2
	[ ${tape[$tptr]} -eq 65534 ]
}

overflow_1() {
	echo "overflow 1 : 65535 + 1"
	$array tape 65535
	cell16 1
	[ ${tape[$tptr]} -eq 0 ]
}

overflow_2() {
	echo "overflow 2 : 65535 + 1 + 1"
	$array tape 65535
	cell16 1
	cell16 1
	[ ${tape[$tptr]} -eq 1 ]
}

overflow_3() {
	echo "overflow 3 : 65535 + 2"
	$array tape 65535
	cell16 2
	[ ${tape[$tptr]} -eq 1 ]
}

n=1
. ../../kbf.sh as a library
init

echo "TAP version 13"
echo "1..6"

ts="overflow_1 overflow_2 overflow_3 underflow_1 underflow_2 underflow_3"
for t in $ts; do
	if title=$(eval $t); then
		echo "ok $n - $title"
	else
		echo "not ok $n - $title"
	fi
	n=$((n + 1))
done

