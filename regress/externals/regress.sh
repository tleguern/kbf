#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu>
# Public domain

cd $(dirname $0)
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
	$kbf $4 $3 > $tmp 2> /dev/null
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
	echo "1..25"
else
	echo "1..27"
fi

t 0 'headcom.res'	'headcom.b'	'-s -t 1'
t 0 '15.res'		'15.b'		'-s -t 2'
t 0 '256.res'		'256.b'		'-s -t 2'
t 0 '256-8bits.res'	'256.b'		'-s -t 2 -c 8'
t 0 'selfsize.res'	'selfsize.b'	'-s -t 3'
t 0 'doubleloop.res'	'doubleloop.b'	'-s -t 3'
t 0 '50cells.res'	'50cells.b'	'-s -t 50'
t 0 'hello.res'		'hello.b'	'-s -t 7'
t 1 '/dev/null'		'cristofd-close.b'
t 0 'O1.res' 'optimisation.b' '-D -O1'
t 0 'O1.res' 'optimisation.b' '-D -o strip-comments'
t 0 'O2.res' 'optimisation.b' '-D -O2'
t 0 'O2.res' 'optimisation.b' '-D -o strip-comments -o optimised-operands'
t 0 'O3.res' 'optimisation.b' '-D -O3'
t 0 'O3.res' 'optimisation.b' '-D -o strip-comments -o strip-null-operations -o optimised-operands -o run-length-encoding'
# Test optimised operands pv
t 0 'op_prevzero.res' 'op_prevzero.b' '-s -o optimised-operands -t 10'
# Test optimised operands nv
t 0 'op_nextzero.res' 'op_nextzero.b' '-s -o optimised-operands -t 10'
# Test optimised operands 0
t 0 'zero.res' 'zero.b' '-s -o optimised-operands -t 2'

# Test RLE optimisation
t 0 '15rle.res' '15.b' '-s -O0 -o run-length-encoding -t 2'
t 0 '256rle.res' '256.b' '-s -O0 -o run-length-encoding -t 2'

# Test Extended Type I operators
t 0 'op_exit_x0.res' 'op_exit.b' '-s -x0 -t10'
t 0 'op_exit_x1.res' 'op_exit.b' '-s -x1 -t10'
t 0 'op_toreg.res' 'op_toreg.b' '-s -x1 -t10 -o optimised-operands'
t 0 'op_fromreg.res' 'op_fromreg.b' '-s -x1 -t10 -o optimised-operands'
t 0 'hello_type1.res' 'hello_type1.b' '-s -x1 -c8 -t10 -O0'

if [ $FULL -eq 1 ]; then
	t 0 '65536.res' '65536.b' '-t2'
	t 0 'bitwidth_O4_c8.res' 'bitwidth.b' '-O4 -c8'
fi

