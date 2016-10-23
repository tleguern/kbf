#!/bin/sh

testfile=../regress/externals/bitwidth.b
shell=ksh

for size in 8 16 24 32s 32u 64s; do
	for opt in 0 1 2 3 4; do
		{ time $shell ../kbf.sh -s -c $size -O$opt $testfile; } > results/$(basename ${testfile%%.b})_c${size}_${opt}.$shell 2>&1
	done
done

