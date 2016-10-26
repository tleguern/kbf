#!/bin/ksh
#
# Copyright (c) 2016 Tristan Le Guern <tleguern@bouledef.eu>
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

trivialbrainfucksubstitution() {
	local sub_op_right="$1"
	local sub_op_left="$2"
	local sub_op_add="$3"
	local sub_op_sub="$4"
	local sub_op_out="$5"
	local sub_op_in="$6"
	local sub_op_open="$7"
	local sub_op_close="$8"
	local op_right="${9:->}"
	local op_left="${10:-<}"
	local op_add="${11:-+}"
	local op_sub="${12:--}"
	local op_out="${13:-.}"
	local op_in="${14:-,}"
	local op_open="${15:-[}"
	local op_close="${16:-]}"

	local OLDIFS="$IFS"
	IFS=$'\n'
	local _i=0
	while [ $_i -lt ${#i[@]} ]; do
		echo "${i[$_i]}"
		case "${i[$_i]}" in
			"$sub_op_right") i[$_i]="$op_right";;
			"$sub_op_left") i[$_i]="$op_left";;
			"$sub_op_add") i[$_i]="$op_add";;
			"$sub_op_sub") i[$_i]="$op_sub";;
			"$sub_op_out") i[$_i]="$op_out";;
			"$sub_op_in") i[$_i]="$op_in";;
			"$sub_op_open") i[$_i]="$op_open";;
			"$sub_op_close") i[$_i]="$op_close";;
			*) :;;
		esac
		_i=$((_i + 1))
	done
	IFS="$OLDIFS"
}

