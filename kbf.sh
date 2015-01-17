#!/bin/ksh

set -e

readonly PROGNAME="`basename $0`"
readonly VERSION='v1.0'

usage() {
	echo "usage: $PROGNAME [-dsD] [-c size] [-t size] [-O level] file[.b]" >&2
}

cflag=32
dflag=0
sflag=0
tflag=999
Oflag=0
Dflag=0
file=''

while getopts ":c:dst:O:D" opt;do
	case $opt in
		c) cflag=$OPTARG;;
		d) dflag=1;;
		s) sflag=1;;
		t) tflag=$OPTARG;;
		O) Oflag=$OPTARG;;
		D) Dflag=1;;
		:) echo "$PROGNAME: option requires an argument -- $OPTARG" >&2;
		   usage; exit 1;;	# NOTREACHED
		\?) echo "$PROGNAME: unkown option -- $OPTARG" >&2;
		   usage; exit 1;;	# NOTREACHED
		*) usage; exit 1;;	# NOTREACHED
	esac
done
shift $(( $OPTIND -1 ))

if [ -z "$1" ]; then
	echo "$PROGNAME: file expected" >&2
	usage
	exit 1
else
	file="$1"
	shift
fi

if [ $# -ge 1 ]; then
	echo "$PROGNAME: invalid trailing chars -- $@" >&2
	usage
	exit 1
fi

set -u

if [ $tflag -le 0 ]; then
	echo "$PROGNAME: tape size is invalid" >&2
	exit 1
fi
if [ $Oflag -lt 0 ] || [ $Oflag -gt 2 ]; then
	echo "$PROGNAME: unsupported optimization level - $Oflag" >&2
	exit 1
fi
if ! [ -e "$file" ]; then
	echo "$PROGNAME: no such file $file" >&2
	exit 1
fi
if ! [ -f "$file" ]; then
	echo "$PROGNAME: invalid file $file" >&2
	exit 1
fi
if ! [ -r "$file" ]; then
	echo "$PROGNAME: can't read $file" >&2
	exit 1
fi

array() {
	set +u
	local _array_name="$1"; shift

	if [ -n "$BASH_VERSION" ]; then
		declare -ga $_array_name
		local _array_i=0
		local _array_j=0
		for _array_i in $@; do
			declare -ga "$_array_name[$_array_j]=$_array_i"
			_array_j=$(( $_array_j + 1 ))
		done
	elif [ -n "$KSH_VERSION" ]; then
		set -A $_array_name -- $@
	else
		echo "Error: unsuported shell :(" >&2
		exit 1
	fi
	set -u
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

matchingbrace() {
	set +u
	local _brace="$1"
	set -u
	local lc=0
	local liptr=$iptr
	local size=${#i[*]}

	if [ "$_brace" = "]" ]; then
		array i "`echo ${i[*]} | rev`"
		liptr=$(( $size - $liptr - 1 ))
	fi
	while [ $liptr -lt $size ]; do
		case ${i[$liptr]} in
			'[') lc=$(( $lc + 1 ));;
			']') lc=$(( $lc - 1 ));;
			*) :;;
		esac
		if [ $lc -eq 0 ]; then
			break
		fi
		liptr=$(( $liptr + 1 ))
	done
	if [ "$_brace" = "]" ]; then
		array i "`echo ${i[*]} | rev`"
		liptr=$(( $size - $liptr - 1 ))
	fi
	if [ $lc -ne 0 ]; then
		echo "Error: Mismatched brace near character $iptr" >&2
		exit 1
	fi
	echo $liptr
}

stats() {
	echo Number of cells used: ${#tape[*]}/$(( $tflag + 1 ))
	echo Number of instructions: $(( $ic - $cc ))
	echo State of the tape: ${tape[*]}
}

opti1() {
	if [ $Oflag -ge 1 ]; then
		tr -Cd '[]<>+\-,.'
	else
		cat
	fi
}

opti2() {
	if [ $Oflag -ge 2 ]; then
		sed 's/\[ - \]/0/g'
	else
		cat
	fi
}

array i "$(cat $file | opti1 | sed 's/./& /g' | opti2)"
array tape 0
tptr=0
ic=0
iptr=0
cc=0

case "$cflag" in
	8) cell=cell8;;
	16) cell=cell16;;
	32) cell=cell32;;
	*) echo "$PROGNAME: Unsupported cell size - $cflag"
	   exit 1;;
esac

[ $Dflag -eq 1 ] && echo ${i[*]} && exit 0

trap stats USR1
[ $dflag -eq 1 ] && echo PID: $$ >&2

while [ $iptr -lt ${#i[*]} ]; do
	jump=0
	case ${i[$iptr]} in
		'>') move +1;;
		'<') move -1;;
		'+') $cell +1;;
		'-') $cell -1;;
		'[') if [ ${tape[$tptr]} -eq 0 ]; then
			jump=$((`matchingbrace '['` + 1))
		     fi;;
		']') if [ ${tape[$tptr]} -ne 0 ]; then
			jump=`matchingbrace ']'`
		     fi;;
		'.') output;;
		',') input;;
		'0') $cell 0;;	# IR operand created by opti2
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

