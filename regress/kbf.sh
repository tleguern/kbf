#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

FAILED=0

kbf=${kbf:-../kbf}

t() {
	# $1 -> exit code
	# $2 -> expected result
	# $3 -> $test expression
	echo "Run $kbf \"$3\", expect exit code $1 and string \"$2\""

	ret="`$kbf $3`"
	if [ $? -ne $1 ]; then
		failed
		return
	fi
	if [ "$ret" != "$2" ]; then
		failed
		return
	fi
	echo OK
}

failed() {
	echo "Failed"
	FAILED=`expr $FAILED + 1`
}

t 0 'Hello World!' 'hello.b'
t 0 '31' 'selfsize.b'
t 0 '' 'headcom.b'

echo ""
echo "Failed: $FAILED"
[ $FAILED -gt 0 ] && exit 1
exit 0

