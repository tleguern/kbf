#!/bin/ksh

test1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell8 -1
	[ ${tape[$tapeidx]} -eq 255 ]
}

test2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell8 -1
	cell8 -1
	[ ${tape[$tapeidx]} -eq 254 ]
}

test3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell8 -2
	[ ${tape[$tapeidx]} -eq 254 ]
}

test4() {
	echo "underflow 4 : 1 - 1 - 1"
	$array tape 1
	cell8 -1
	cell8 -1
	[ ${tape[$tapeidx]} -eq 255 ]
}

test5() {
	echo "underflow 5 : 1 - 2"
	$array tape 1
	cell8 -2
	[ ${tape[$tapeidx]} -eq 255 ]
}

test6() {
	echo "underflow 6 : 1 - 255"
	$array tape 1
	cell8 -255
	[ ${tape[$tapeidx]} -eq 2 ]
}

test7() {
	echo "overflow 1 : 255 + 1"
	$array tape 255
	cell8 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

test8() {
	echo "overflow 2 : 255 + 1 + 1"
	$array tape 255
	cell8 1
	cell8 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

test9() {
	echo "overflow 3 : 255 + 2"
	$array tape 255
	cell8 2
	[ ${tape[$tapeidx]} -eq 1 ]
}

n=1
max=9
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

