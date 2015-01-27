#!/bin/ksh
#
# Copyright (c) 2014-2015 Tristan Le Guern <tleguern@bouledef.eu>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

set -e

readonly KBFPROGNAME="`basename $0`"
readonly VERSION='v1.0'

usage() {
	echo "usage: $KBFPROGNAME [-dsD] [-c size] [-t size] [-O level] file[.b]" >&2
}

cflag=32
dflag=0
sflag=0
tflag=999
Oflag=0
Dflag=0
file=''

op_add='+'
op_sub='-'
op_left='<'
op_right='>'
op_open='['
op_close=']'
op_in=','
op_out='.'

arrayksh() {
	local _array_name="$1"
	shift
	set -A $_array_name -- ${@:-''}
}

arraybash() {
	local _array_name="$1"
	shift
	unset $_array_name
	declare -ga $_array_name
	local _array_i=0
	local _array_j=0
	for _array_i in "$@"; do
		declare -ga "$_array_name[$_array_j]=$_array_i"
		_array_j=$(( $_array_j + 1 ))
	done
}

arrayzsh() {
	local _array_name="$1"
	shift
	unset $_array_name
	typeset -ga $_array_name
	local _array_i=0
	local _array_j=0
	for _array_i in $@; do
		typeset -g "$_array_name[$_array_j]"="$_array_i"
		_array_j=$(( $_array_j + 1 ))
	done
}

move() {
	set +u
	local _index=$(( $tptr + $1 ))
	set -u

	if [ $_index -lt 0 ]; then
		echo "Error: Can't move pointer bellow zero" >&2
		exit 1
	fi
	if [ $_index -gt $tflag ]; then
		echo "Error: Reached max tape size" >&2
		exit 1
	fi
	if [ $_index -ge ${#tape[@]} ]; then
		tape[$_index]=0
	fi
	tptr=$_index
}

cell8() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tptr]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tptr]=0
	elif [ $_nvalue -gt 255 ]; then
		_nvalue=$(($_nvalue - 256))
		cell8 $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 256))
		cell8 $_nvalue
	else
		tape[$tptr]=$_nvalue
	fi
}

cell16() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tptr]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tptr]=0
	elif [ $_nvalue -gt 65535 ]; then
		_nvalue=$(($_nvalue - 65536))
		cell16 $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 65536))
		cell16 $_nvalue
	else
		tape[$tptr]=$_nvalue
	fi
}

cell32() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tptr]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tptr]=0
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 9223372036854775808))
		cell32 $_nvalue
	else
		tape[$tptr]=$_nvalue
	fi
}

output() {
	awk -v v=${tape[$tptr]} 'BEGIN { printf "%c", v; exit }'
}

input() {
	stty raw
	local char="`dd bs=1 count=1 2> /dev/null`"
	stty -raw
	tape[$tptr]=`printf "%d" "'$char"`
}

matchingclosebracket() {
	local lc=0
	local liptr=$iptr
	local size=${#i[*]}

	while [ $liptr -lt $size ]; do
		case "${i[$liptr]}" in
			"$op_open") lc=$(( $lc + 1 ));;
			"$op_close") lc=$(( $lc - 1 ));;
			*) :;;
		esac
		if [ $lc -eq 0 ]; then
			break
		fi
		liptr=$(( $liptr + 1 ))
	done
	if [ $lc -ne 0 ]; then
		echo "Error: Mismatched bracket near character $iptr" >&2
		exit 1
	fi
	echo $liptr
}

matchingopenbracket() {
	local lc=0
	local liptr=$iptr
	local size=${#i[*]}

	while [ $liptr -gt 0 ]; do
		case "${i[$liptr]}" in
			"$op_open") lc=$(( $lc + 1 ));;
			"$op_close") lc=$(( $lc - 1 ));;
			*) :;;
		esac
		if [ $lc -eq 0 ]; then
			break
		fi
		liptr=$(( $liptr - 1 ))
	done
	if [ $lc -ne 0 ]; then
		echo "Error: Mismatched bracket near character $iptr" >&2
		exit 1
	fi
	echo $liptr
}

nextzero() {
	local ltptr=$tptr
	local size=${#tape[*]}

	while [ $ltptr -lt $size ]; do
		if [ ${tape[$ltptr]} -eq 0 ]; then
			break
		fi
		ltptr=$(( $ltptr + 1 ))
	done
	tptr=$ltptr
}

prevzero() {
	local ltptr=$tptr

	while [ $ltptr -gt 0 ]; do
		if [ ${tape[$ltptr]} -eq 0 ]; then
			break
		fi
		ltptr=$(( $ltptr - 1 ))
	done
	tptr=$ltptr
}

stats() {
	echo Number of cells used: ${#tape[*]}/$(( $tflag + 1 ))
	echo Number of instructions: $(( $ic - $cc ))
	echo State of the tape: ${tape[*]}
}

opti1() {
	if [ $Oflag -ge 1 ]; then
		tr -Cd "\\${op_open}\\${op_close}\\${op_left}\\${op_right}\\${op_add}\\${op_sub}\\${op_in}\\${op_out}"
	else
		cat
	fi
}

opti2() {
	set +u
	local _i="$*"
	set -u
	if [ $Oflag -ge 2 ]; then
		count=${#_i}
		while true; do
			_i=$(echo $_i | sed "s/\\$op_open\\$op_close//g" \
			    | sed "s/$op_add$op_sub//g" \
			    | sed "s/$op_sub$op_add//g" \
			    | sed "s/$op_left$op_right//g" \
			    | sed "s/$op_right$op_left//g")
			if [ $count -eq ${#_i} ]; then
				break
			else
				count=${#_i}
			fi
		done
	fi
	echo "$_i"
}

opti3() {
	if [ $Oflag -ge 3 ]; then
		sed "s/\\$op_open $op_sub \\$op_close/0/g" \
		    | sed "s/\\$op_open $op_right \\$op_close/>>/g" \
		    | sed "s/\\$op_open $op_left \\$op_close/<</g"
	else
		cat
	fi
}

init() {
	tptr=0
	ic=0
	iptr=0
	cc=0

	set +u
	if [ -n "$BASH_VERSION" ]; then
		array=arraybash
	elif [ -n "$KSH_VERSION" ]; then
		array=arrayksh
	elif [ -n "$ZSH_VERSION" ]; then
		setopt ksharrays
		array=arrayzsh
	else
		echo "Error: unsuported shell :(" >&2
		exit 1
	fi
	set -u

	case "$cflag" in
		8) cell=cell8;;
		16) cell=cell16;;
		32) cell=cell32;;
		*) echo "$KBFPROGNAME: Unsupported cell size - $cflag"
		   exit 1;;
	esac
}

kbf() {
	[ $Dflag -eq 1 ] && echo "${i[*]}" && exit 0

	trap stats USR1

	while [ $iptr -lt ${#i[*]} ]; do
		jump=0
		case ${i[$iptr]} in
			"$op_right")
				move +1;;
			"$op_left")
				move -1;;
			"$op_add")
				$cell +1;;
			"$op_sub")
				$cell -1;;
			"$op_open")
				if [ ${tape[$tptr]} -eq 0 ]; then
					jump=$(($(matchingclosebracket) + 1))
				fi;;
			"$op_close")
				if [ ${tape[$tptr]} -ne 0 ]; then
					jump=$(matchingopenbracket)
				fi;;
			"$op_out")
				output;;
			'0')
				$cell 0;;
			"$op_in")
				input;;
			'<<')
				prevzero;;
			'>>')
				nextzero;;
			*) cc=$(( $cc + 1 ));;
		esac
		[ $dflag -eq 1 ] && echo " ${i[$iptr]}: [$tptr]=${tape[$tptr]}" >&2

		ic=$(( $ic + 1 ))
		if [ $jump -gt 0 ]; then
			iptr=$jump
		else
			iptr=$(( $iptr + 1 ))
		fi
	done

	if [ $sflag -eq 1 ]; then
		stats
	fi
}

if [ "${KBFPROGNAME%.sh}" = "kbf" ]; then
	while getopts ":c:dst:O:D" opt;do
		case $opt in
			c) cflag=$OPTARG;;
			d) dflag=1;;
			s) sflag=1;;
			t) tflag=$OPTARG;;
			O) Oflag=$OPTARG;;
			D) Dflag=1;;
			:) echo "$KBFPROGNAME: option requires an argument -- $OPTARG" >&2;
			   usage; exit 1;;	# NOTREACHED
			\?) echo "$KBFPROGNAME: unkown option -- $OPTARG" >&2;
			   usage; exit 1;;	# NOTREACHED
			*) usage; exit 1;;	# NOTREACHED
		esac
	done
	shift $(( $OPTIND -1 ))

	if [ -z "$1" ]; then
		echo "$KBFPROGNAME: file expected" >&2
		usage
		exit 1
	else
		file="$1"
		shift
	fi

	if [ $# -ge 1 ]; then
		echo "$KBFPROGNAME: invalid trailing chars -- $@" >&2
		usage
		exit 1
	fi

	set -u

	if [ $tflag -le 0 ]; then
		echo "$KBFPROGNAME: tape size is invalid" >&2
		exit 1
	fi
	if [ $Oflag -lt 0 ] || [ $Oflag -gt 3 ]; then
		echo "$KBFPROGNAME: unsupported optimization level - $Oflag" >&2
		exit 1
	fi
	if ! [ -e "$file" ]; then
		echo "$KBFPROGNAME: no such file $file" >&2
		exit 1
	fi
	if ! [ -f "$file" ]; then
		echo "$KBFPROGNAME: invalid file $file" >&2
		exit 1
	fi
	if ! [ -r "$file" ]; then
		echo "$KBFPROGNAME: can't read $file" >&2
		exit 1
	fi

	init
	i="$(cat $file | opti1)"
	i="$(opti2 $i)"
	$array i $(echo "$i" | sed 's/./& /g' | opti3)
	$array tape 0
	kbf
fi
