#!/bin/sh
# Tristan Le Guern <tleguern@bouledef.eu> - Public domain

set -e

file=$(mktemp)

for i in *.b; do
	../kbf.sh -D -O 2 $i >> $file
	echo "" >> $file
done

cat $file | tr ' ' '\n' | sort | uniq -c | sort -nr
