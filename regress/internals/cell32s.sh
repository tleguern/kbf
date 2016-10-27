#!/bin/sh

underflow_1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell32s -1
	[ ${tape[$tapeidx]} -eq 2147483647 ]
}

underflow_2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell32s -1
	cell32s -1
	[ ${tape[$tapeidx]} -eq 2147483646 ]
}

underflow_3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell32s -2
	[ ${tape[$tapeidx]} -eq 2147483646 ]
}

overflow_1() {
	echo "overflow 1 : 2147483647 + 1"
	$array tape 2147483647
	cell32s 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

overflow_2() {
	echo "overflow 2 : 2147483647 + 1 + 1"
	$array tape 2147483647
	cell32s 1
	cell32s 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

overflow_3() {
	echo "overflow 3 : 2147483647 + 2"
	$array tape 2147483647
	cell32s 2
	[ ${tape[$tapeidx]} -eq 1 ]
}

n=1
cd $(dirname $0)
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

