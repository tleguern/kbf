#!/bin/ksh
#
# Copyright (c) 2014-2016 Tristan Le Guern <tleguern@bouledef.eu>
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
readonly KBFVERSION='v2.0'

usage() {
	echo "usage: $KBFPROGNAME [-dsD] [-c size] [-o flag] [-t size] [-O level] file[.b]" >&2
}

cflag=24
dflag=0
ostrip_comments=0
ostrip_null_operations=0
ooptimised_operands=0
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
	unset "$_array_name"
	OLDIFS="$IFS"
	IFS="
"
	set -A $_array_name -- ${@:-''}
	IFS="$OLDIFS"
}

_arraybash() {
	local _array_name="$1"
	shift
	unset $_array_name
	declare -ga $_array_name
	local _array_i=0
	local _array_j=0
	for _array_i in "$@"; do
		eval $_array_name[$_array_j]="\"$_array_i\""
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
	local _index=$(( $tapeidx + $1 ))
	set -u

	if [ $_index -lt 0 ]; then
		echo "$KBFPROGNAME: can not move pointer bellow zero" >&2
		exit 1
	fi
	if [ $_index -gt $tflag ]; then
		echo "$KBFPROGNAME: reached max tape size" >&2
		exit 1
	fi
	tapeidx=$_index
}

cell8() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -gt 255 ]; then
		_nvalue=$(($_nvalue - 256))
		tape[$tapeidx]=0
		cell8 $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 256))
		cell8 $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

cell16() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -gt 65535 ]; then
		_nvalue=$(($_nvalue - 65536))
		tape[$tapeidx]=0
		cell16 $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 65536))
		cell16 $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

cell24() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -gt 16777215 ]; then
		_nvalue=$(($_nvalue - 16777216))
		tape[$tapeidx]=0
		cell24 $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 16777216))
		cell24 $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

# max cell size for mksh 46
cell32s() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -gt 2147483647 ]; then	# Necessary for int64 shells
		_nvalue=$(($_nvalue - 2147483648))
		tape[$tapeidx]=0
		cell32s $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 2147483648))
		tape[$tapeidx]=0
		cell32s $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

cell32u() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -gt 4294967295 ]; then
		_nvalue=$(($_nvalue - 4294967296))
		tape[$tapeidx]=0
		cell32u $_nvalue
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 4294967296))
		tape[$tapeidx]=0
		cell32u $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

# max cell size for bash 4.3
cell64s() {
	set +u
	local _value="$1"
	set -u
	local _nvalue=$(( ${tape[$tapeidx]} + $_value ))

	if [ $_value -eq 0 ]; then
		tape[$tapeidx]=0
	elif [ $_nvalue -lt 0 ]; then
		_nvalue=$(($_nvalue + 9223372036854775808))
		tape[$tapeidx]=0
		cell64s $_nvalue
	else
		tape[$tapeidx]=$_nvalue
	fi
}

output() {
	awk -v v=${tape[$tapeidx]} 'BEGIN { printf "%c", v; exit }'
}

input() {
	stty raw
	local char="$(dd bs=1 count=1 2> /dev/null)"
	stty -raw
	tape[$tapeidx]=$(printf "%d" "'$char")
}

matchingclosebracket() {
	local lc=0
	local linstidx=$instidx
	local size=${#instructions[*]}

	while [ $linstidx -lt $size ]; do
		case "${instructions[$linstidx]}" in
			"$op_open") lc=$(( $lc + 1 ));;
			"$op_close") lc=$(( $lc - 1 ));;
			*) :;;
		esac
		if [ $lc -eq 0 ]; then
			break
		fi
		linstidx=$(( $linstidx + 1 ))
	done
	if [ $lc -ne 0 ]; then
		echo "Error: Mismatched bracket near character $instidx" >&2
		exit 1
	fi
	echo $linstidx
}

matchingopenbracket() {
	local lc=0
	local linstidx=$instidx
	local size=${#instructions[*]}

	while [ $linstidx -gt 0 ]; do
		case "${instructions[$linstidx]}" in
			"$op_open") lc=$(( $lc + 1 ));;
			"$op_close") lc=$(( $lc - 1 ));;
			*) :;;
		esac
		if [ $lc -eq 0 ]; then
			break
		fi
		linstidx=$(( $linstidx - 1 ))
	done
	if [ $lc -ne 0 ]; then
		echo "Error: Mismatched bracket near character $instidx" >&2
		exit 1
	fi
	echo $linstidx
}

nextzero() {
	local ltapeidx=$tapeidx
	local size=${#tape[*]}

	while [ $ltapeidx -lt $size ]; do
		if [ ${tape[$ltapeidx]} -eq 0 ]; then
			break
		fi
		ltapeidx=$(( $ltapeidx + 1 ))
	done
	tapeidx=$ltapeidx
}

prevzero() {
	local ltapeidx=$tapeidx

	while [ $ltapeidx -gt 0 ]; do
		if [ ${tape[$ltapeidx]} -eq 0 ]; then
			break
		fi
		ltapeidx=$(( $ltapeidx - 1 ))
	done
	tapeidx=$ltapeidx
}

stats() {
	echo Number of instructions: $(( $instrcount - $commentscount ))
	echo State of the tape: ${tape[*]}
	echo Pointer on cell: $tapeidx
}

strip_comments() {
	if [ $ostrip_comments -eq 1 ]; then
		tr -Cd "\\${op_open}\\${op_close}\\${op_left}\\${op_right}\\${op_add}\\${op_sub}\\${op_in}\\${op_out}"
	else
		cat
	fi
}

strip_null_operations() {
	local _i="$*"
	local _count=0

	if [ $ostrip_null_operations -eq 1 ]; then
		_count=${#_i}
		while true; do
			_i=$(echo $_i | sed "s/$op_add$op_sub//g" \
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

optimised_operands() {
	if [ $ooptimised_operands -eq 1 ]; then
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
	tapeidx=0
	instrcount=0
	instidx=0
	commentscount=0

	set +u
	if [ -n "$BASH_VERSION" ]; then
		array=_arraybash
	elif [ -n "$KSH_VERSION" ]; then
		array=_arrayksh
	elif [ -n "$ZSH_VERSION" ]; then
		setopt ksharrays
		setopt sh_word_split
		array=_arrayksh
	else
		echo "$KBFPROGNAME: unsupported shell" >&2
		exit 1
	fi
	set -u

	case "$cflag" in
		8) cell=cell8;;
		16) cell=cell16;;
		24) cell=cell24;;
		32s) cell=cell32s;;
		32u) cell=cell32u;;
		64s) cell=cell64s;;
		*) echo "$KBFPROGNAME: unsupported cell size - $cflag"
		   exit 1;;
	esac
}

kbf() {
	[ $Dflag -eq 1 ] && echo "${instructions[*]}" && exit 0

	trap stats USR1

	while [ $instidx -lt ${#instructions[*]} ]; do
		local _jump=0
		local _inst="${instructions[$instidx]}"
		case $_inst in
			"$op_right"*)
				move +${#_inst};;
			"$op_left"*)
				move -${#_inst};;
			"$op_add"*)
				$cell ${#_inst};;
			"$op_sub"*)
				$cell -${#_inst};;
			"$op_open")
				if [ ${tape[$tapeidx]} -eq 0 ]; then
					_jump=$(($(matchingclosebracket) + 1))
				fi;;
			"$op_close")
				if [ ${tape[$tapeidx]} -ne 0 ]; then
					_jump=$(matchingopenbracket)
				fi;;
			"$op_out")
				output;;
			"$op_clear")
				if [ ${tape[$tapeidx]} -ne 0 ]; then
					$cell 0
				fi;;
			"$op_in")
				input;;
			"$op_prevzero")
				if [ ${tape[$tapeidx]} -ne 0 ]; then
					prevzero
				fi;;
			"$op_nextzero")
				if [ ${tape[$tapeidx]} -ne 0 ]; then
					nextzero
				fi;;
			*) commentscount=$(( $commentscount + 1 ));;
		esac
		if [ $dflag -eq 1 ]; then
			echo " $_inst: [$tapeidx]=${tape[$tapeidx]}" >&2
		fi

		instrcount=$(( $instrcount + 1 ))
		if [ $_jump -gt 0 ]; then
			instidx=$_jump
		else
			instidx=$(( $instidx + 1 ))
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
		"strip-null-operations") ostrip_null_operations=1;;
		"optimised-operands") ooptimised_operands=1;;
		"run-length-encoding") orun_length_encoding=1;;
		*) usage; exit 1;;
	esac
}

if [ "${KBFPROGNAME%.sh}" = "kbf" ] && [ "$*" != "as a library" ]; then
	while getopts ":c:do:st:O:D" opt; do
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
			\?) echo "$KBFPROGNAME: unknown option -- $OPTARG" >&2;
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
		   ostrip_null_operations=1;;
		3) ostrip_comments=1
		   ostrip_null_operations=1
		   ooptimised_operands=1;;
		4) ostrip_comments=1
		   ostrip_null_operations=1
		   ooptimised_operands=1
		   orun_length_encoding=1;;
		*) echo "$KBFPROGNAME: unsupported optimisation level - $Oflag"\
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
		echo "$KBFPROGNAME: can not read $file" >&2
		exit 1
	fi

	init
	instructions="$(cat $file)"
	instructions="$(echo $instructions | strip_comments)"
	instructions="$(strip_null_operations $instructions)"
	instructions="$(echo $instructions | sed 's/./& /g')"
	instructions="$(optimised_operands $instructions)"
	instructions="$(run_length_encoding $instructions)"
	$array instructions $instructions
	$array tape $(_givemesomezeros $tflag)
	kbf
fi

