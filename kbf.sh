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
set -f

readonly KBFPROGNAME="$(basename $0)"
readonly KBFVERSION='v1.0'

usage() {
	echo "usage: $KBFPROGNAME [-dsD] [-c size] [-o flag] [-t size] [-O level] file[.b]" >&2
}

cflag=32
dflag=0
ostrip_comments=0
ostrip_empty_and_null=0
ooptimized_operands=0
orun_length_encoding=0
sflag=0
tflag=999
Oflag=1
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
op_clear='0'
op_nextzero='}'
op_prevzero='{'

_arrayksh() {
	# Very slow with big list of arguments.
	local _array_name="$1"
	shift
	set -A $_array_name -- ${@:-''}
}

_arraybash() {
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

_arrayzsh() {
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

_givemesomezeros() {
	local _i=$1
	while ((_i--)); do
		echo 0
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
	local char="$(dd bs=1 count=1 2> /dev/null)"
	stty -raw
	tape[$tptr]=$(printf "%d" "'$char")
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
	echo Number of instructions: $(( $ic - $cc ))
	echo State of the tape: ${tape[*]}
	echo Pointer on cell: $tptr
}

strip_comments() {
	if [ $ostrip_comments -eq 1 ]; then
		tr -Cd "\\${op_open}\\${op_close}\\${op_left}\\${op_right}\\${op_add}\\${op_sub}\\${op_in}\\${op_out}"
	else
		cat
	fi
}

strip_empty_and_null() {
	local _i="$*"
	local _count=0

	if [ $ostrip_empty_and_null -eq 1 ]; then
		_count=${#_i}
		while true; do
			_i=$(echo $_i | sed "s/\\$op_open\\$op_close//g" \
			    | sed "s/$op_add$op_sub//g" \
			    | sed "s/$op_sub$op_add//g" \
			    | sed "s/$op_left$op_right//g" \
			    | sed "s/$op_right$op_left//g")
			if [ $_count -eq ${#_i} ]; then
				break
			else
				_count=${#_i}
			fi
		done
	fi
	echo "$_i"
}

optimized_operands() {
	if [ $ooptimized_operands -eq 1 ]; then
		echo "$*" | sed "s/\\$op_open $op_sub \\$op_close/$op_clear/g" \
		    | sed "s/\\$op_open $op_right \\$op_close/$op_nextzero/g" \
		    | sed "s/\\$op_open $op_left \\$op_close/$op_prevzero/g"
	else
		echo $*
	fi
}

run_length_encoding() {
	if [ $orun_length_encoding -eq 1 ]; then
		local _c=""
		local _prev=""
		local _i=""
		for _i in $*; do
			_prev="${_prev:=$_i}"

			if ( [ "$_i" = "$op_add" ] || [ "$_i" = "$op_sub" ] \
			    || [ "$_i" = "$op_right" ] \
			    || [ "$_i" = "$op_left" ] ) \
			    && [ "$_i" = "$_prev" ]; then
				_c="$_c$_i"
			else
				echo -n "$_c "
				_prev="$_i"
				_c="$_i"
			fi
		done
		echo "$_c"
	else
		echo $*
	fi
}

init() {
	tptr=0
	ic=0
	iptr=0
	cc=0

	set +u
	if [ -n "$BASH_VERSION" ]; then
		array=_arraybash
	elif [ -n "$KSH_VERSION" ]; then
		array=_arrayksh
	elif [ -n "$ZSH_VERSION" ]; then
		setopt ksharrays
		array=_arrayzsh
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
		local _jump=0
		local _in="${i[$iptr]}"
		case $_in in
			"$op_right"*)
				move +${#_in};;
			"$op_left"*)
				move -${#_in};;
			"$op_add"*)
				$cell ${#_in};;
			"$op_sub"*)
				$cell -${#_in};;
			"$op_open")
				if [ ${tape[$tptr]} -eq 0 ]; then
					_jump=$(($(matchingclosebracket) + 1))
				fi;;
			"$op_close")
				if [ ${tape[$tptr]} -ne 0 ]; then
					_jump=$(matchingopenbracket)
				fi;;
			"$op_out")
				output;;
			"$op_clear")
				if [ ${tape[$tptr]} -ne 0 ]; then
					$cell 0
				fi;;
			"$op_in")
				input;;
			"$op_prevzero")
				if [ ${tape[$tptr]} -ne 0 ]; then
					prevzero
				fi;;
			"$op_nextzero")
				if [ ${tape[$tptr]} -ne 0 ]; then
					nextzero
				fi;;
			*) cc=$(( $cc + 1 ));;
		esac
		[ $dflag -eq 1 ] && echo " $_in: [$tptr]=${tape[$tptr]}" >&2

		ic=$(( $ic + 1 ))
		if [ $_jump -gt 0 ]; then
			iptr=$_jump
		else
			iptr=$(( $iptr + 1 ))
		fi
	done

	if [ $sflag -eq 1 ]; then
		stats
	fi
}

_getsubopts() {
	local _subopt="$1"

	case "$_subopt" in
		"strip-comments") ostrip_comments=1;;
		"strip-empty-and-null") ostrip_empty_and_null=1;;
		"optimized-operands") ooptimized_operands=1;;
		"run-length-encoding") orun_length_encoding=1;;
		*) usage; exit 1;;
	esac
}

if [ "${KBFPROGNAME%.sh}" = "kbf" ]; then
	while getopts ":c:do:st:O:D" opt;do
		case $opt in
			c) cflag=$OPTARG;;
			d) dflag=1;;
			o) _getsubopts $OPTARG;;
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
	case "$Oflag" in
		0):;;
		1) ostrip_comments=1;;
		2) ostrip_comments=1
		   ostrip_empty_and_null=1;;
		3) ostrip_comments=1
		   ostrip_empty_and_null=1
		   ooptimized_operands=1;;
		4) ostrip_comments=1
		   ostrip_empty_and_null=1
		   ooptimized_operands=1
		   orun_length_encoding=1;;
		*) echo "$KBFPROGNAME: unsupported optimization level - $Oflag"\
		    >&2
		   exit 1;;
	esac
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
	i="$(cat $file)"
	i="$(echo $i | strip_comments)"
	i="$(strip_empty_and_null $i)"
	i="$(echo $i | sed 's/./& /g')"
	i="$(optimized_operands $i)"
	i="$(run_length_encoding $i)"
	$array i $i
	$array tape $(_givemesomezeros $tflag)
	kbf
fi

