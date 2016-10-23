#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu> - Public domain

TESTFILE=${TESTFILE:-../regress/externals/bitwidth.b}
SHELL=${SHELL:-ksh}

for size in 8 16 24 32s 32u 64s; do
	for opt in 0 1 2 3 4; do
		{ time $SHELL ../kbf.sh -s -c $size -O$opt $TESTFILE; } > results/$(basename ${TESTFILE%%.b})_c${size}_${opt}.$SHELL 2>&1
	done
done

