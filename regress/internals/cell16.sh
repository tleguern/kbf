#!/bin/ksh

test1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell16 -1
	[ ${tape[$tapeidx]} -eq 65535 ]
}

test2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell16 -1
	cell16 -1
	[ ${tape[$tapeidx]} -eq 65534 ]
}

test3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell16 -2
	[ ${tape[$tapeidx]} -eq 65534 ]
}

test4() {
	echo "underflow 4 : 1 - 1 -1"
	$array tape 1
	cell16 -1
	cell16 -1
	[ ${tape[$tapeidx]} -eq 65535 ]
}

test5() {
	echo "underflow 5 : 1 - 2"
	$array tape 1
	cell16 -2
	[ ${tape[$tapeidx]} -eq 65535 ]
}

test6() {
	echo "overflow 1 : 65535 + 1"
	$array tape 65535
	cell16 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

test7() {
	echo "overflow 2 : 65535 + 1 + 1"
	$array tape 65535
	cell16 1
	cell16 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

test8() {
	echo "overflow 3 : 65535 + 2"
	$array tape 65535
	cell16 2
	[ ${tape[$tapeidx]} -eq 1 ]
}

n=1
max=8
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

