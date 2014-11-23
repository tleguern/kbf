#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

FAILED=0

kbf=${kbf:-../kbf}

t() {
	# $1 -> exit code
	# $2 -> file containing the expected result
	# $3 -> $test expression
	echo "Run $kbf \"$3\", expect exit code $1"

	tmp=`mktemp -t kbf.XXXXXXXX`
	if ! $kbf -s $3 > $tmp 2> /dev/null; then
		failed
		rm $tmp
		return
	fi
	if ! diff -u $2 $tmp > /dev/null 2> /dev/null; then
		failed
		rm $tmp
		return
	fi
	rm $tmp
	echo OK
}

failed() {
	echo "Failed"
	FAILED=`expr $FAILED + 1`
}

t 0 'headcom.res' 'headcom.b'
t 0 '15.res' '15.b'
t 0 '40.res' '40.b'
t 0 'selfsize.res' 'selfsize.b'
t 0 'doubleloop.res' 'doubleloop.b'
t 0 'hello.res' 'hello.b'

echo ""
echo "Failed: $FAILED"
[ $FAILED -gt 0 ] && exit 1
exit 0

