#!/bin/ksh

test1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell32s -1
	[ ${tape[$tapeidx]} -eq 2147483647 ]
}

test2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell32s -1
	cell32s -1
	[ ${tape[$tapeidx]} -eq 2147483646 ]
}

test3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell32s -2
	[ ${tape[$tapeidx]} -eq 2147483646 ]
}

test4() {
	echo "overflow 1 : 2147483647 + 1"
	$array tape 2147483647
	cell32s 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

test5() {
	echo "overflow 2 : 2147483647 + 1 + 1"
	$array tape 2147483647
	cell32s 1
	cell32s 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

test6() {
	echo "overflow 3 : 2147483647 + 2"
	$array tape 2147483647
	cell32s 2
	[ ${tape[$tapeidx]} -eq 1 ]
}

n=1
max=6
cd $(dirname $0)
. ../../kbf.sh as a library
init

echo "TAP version 13"
echo "1..$max"

while [ $n -le $max ]; do
	if title=$(eval test$n); then
		echo "ok $n - $title"
	else
		echo "not ok $n - $title"
	fi
	n=$((n + 1))
done

