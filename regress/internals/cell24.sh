#!/bin/ksh

test1() {
	echo "underflow 1 : 0 - 1"
	$array tape 0
	cell24 -1
	[ ${tape[$tapeidx]} -eq 16777215 ]
}

test2() {
	echo "underflow 2 : 0 - 1 - 1"
	$array tape 0
	cell24 -1
	cell24 -1
	[ ${tape[$tapeidx]} -eq 16777214 ]
}

test3() {
	echo "underflow 3 : 0 - 2"
	$array tape 0
	cell24 -2
	[ ${tape[$tapeidx]} -eq 16777214 ]
}

test4() {
	echo "overflow 1 : 16777215 + 1"
	$array tape 16777215
	cell24 1
	[ ${tape[$tapeidx]} -eq 0 ]
}

test5() {
	echo "overflow 2 : 16777215 + 1 + 1"
	$array tape 16777215
	cell24 1
	cell24 1
	[ ${tape[$tapeidx]} -eq 1 ]
}

test6() {
	echo "overflow 3 : 16777215 + 2"
	$array tape 16777215
	cell24 2
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

