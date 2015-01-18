#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

FAILED=0

kbf=${kbf:-../kbf.sh}
FULL=${FULL:-0}

t() {
	# $1 -> exit code
	# $2 -> file containing the expected result
	# $3 -> $test expression
	# $4 -> Options to kbf
	echo "Run $kbf $4 \"$3\", expect exit code $1"

	tmp=`mktemp -t kbf.XXXXXXXX`
	set +e
	$kbf $4 -s $3 > $tmp 2> /dev/null
	ret=$?
	set -e
	if [ $ret -ne $1 ]; then
		echo "Wrong exit code for $3 ($ret)"
		failed
		rm $tmp
		return
	fi
	set +e
	diff -u $2 $tmp > /dev/null 2> /dev/null
	ret=$?
	set -e
	if [ $ret -ne $1 ]; then
		echo "Wrong result for $3 ($ret)"
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
t 0 '256.res' '256.b'
t 0 '256-8bits.res' '256.b' '-c 8'
t 0 'selfsize.res' 'selfsize.b'
t 0 'doubleloop.res' 'doubleloop.b'
t 0 '50cells.res' '50cells.b'
t 0 'hello.res' 'hello.b'
t 1 '/dev/null' 'cristofd-close.b'
[ $FULL -eq 1 ] && t 0 '65536.res' '65536.b'

echo ""
echo "Failed: $FAILED"
[ $FAILED -gt 0 ] && exit 1
exit 0

