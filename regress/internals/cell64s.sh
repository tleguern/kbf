#!/bin/ksh

test1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell64s -1
	[ ${tape[$tapeidx]} -eq 9223372036854775807 ]
}

test2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell64s -1
	cell64s -1
	[ ${tape[$tapeidx]} -eq 9223372036854775806 ]
}

test3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell64s -2
	[ ${tape[$tapeidx]} -eq 9223372036854775806 ]
}

test4() {
	echo "overflow 1 : 9223372036854775807 + 1"
	$array tape 9223372036854775807
	cell64s 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

test5() {
	echo "overflow 2 : 9223372036854775807 + 1 + 1"
	$array tape 9223372036854775807
	cell64s 1
	cell64s 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

test6() {
	echo "overflow 3 : 9223372036854775807 + 2"
	$array tape 9223372036854775807
	cell64s 2
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

