#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

n=0
kbf=${kbf:-../../kbf.sh}
FULL=${FULL:-0}

t() {
	# $1 -> exit code
	# $2 -> file containing the expected result
	# $3 -> $test expression
	# $4 -> Options to kbf

	title="$kbf $4 \"$3\", exit code $1"
	n=$((n + 1))

	tmp=$(mktemp -t kbf.XXXXXXXX)
	set +e
	$kbf $4 -s $3 > $tmp 2> /dev/null
	ret=$?
	set -e
	if [ $ret -ne $1 ]; then
		echo "not ok $n - $title (wrong exit code $ret)"
		rm $tmp
		return
	fi
	set +e
	diff -u $2 $tmp > /dev/null 2> /dev/null
	ret=$?
	set -e
	if [ $ret -ne $1 ]; then
		echo "not ok $n - $title (wrong result)"
		rm $tmp
		return
	fi
	rm $tmp
	echo "ok $n - $title"
}

echo "TAP version 13"
if [ "$FULL" = "0" ]; then
	echo "1..23"
else
	echo "1..25"
fi

t 0 'headcom.res'	'headcom.b'	'-t 1'
t 0 '15.res'		'15.b'		'-t 2'
t 0 '256.res'		'256.b'		'-t 2'
t 0 '256-8bits.res'	'256.b'		'-t 2 -c 8'
t 0 'selfsize.res'	'selfsize.b'	'-t 3'
t 0 'doubleloop.res'	'doubleloop.b'	'-t 3'
t 0 '50cells.res'	'50cells.b'	'-t 50'
t 0 'hello.res'		'hello.b'	'-t 7'
t 1 '/dev/null'		'cristofd-close.b'
t 0 'O1.res' 'optimization.b' '-D -O1'
t 0 'O1.res' 'optimization.b' '-D -o strip-comments'
t 0 'O2.res' 'optimization.b' '-D -O2'
t 0 'O2.res' 'optimization.b' '-D -o strip-comments -o strip-empty-and-null'
t 0 'O3.res' 'optimization.b' '-D -O3'
t 0 'O3.res' 'optimization.b' '-D -o strip-comments -o strip-empty-and-null -o optimized-operands'
t 0 'prevzero.res'	'prevzero.b'	'-o optimized-operands -t 10'
t 0 'prevzero_op.res'	'prevzero_op.b'	'-O0 -t 10'
t 0 'nextzero.res'	'nextzero.b'	'-o optimized-operands -t 10'
t 0 'nextzero_op.res'	'nextzero_op.b'	'-O0 -t 10'
t 0 'zero.res'		'zero.b'	'-o optimized-operands -t 2'
t 0 'zero_op.res'	'zero_op.b'	'-O0 -t 2'
t 0 '15rle.res'		'15.b'	'-O0 -o run-length-encoding -t 2'
t 0 '256rle.res'	'256.b'	'-O0 -o run-length-encoding -t 2'

if [ $FULL -eq 1 ]; then
	t 0 '65536.res' '65536.b' '-t2'
	t 0 'bitwidth_O4_c8.res' 'bitwidth.b' '-O4 -c8'
fi

