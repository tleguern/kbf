#!/bin/ksh

. ../kbf.sh

init

op_right="a"
op_left="c"
op_add="e"
op_sub="i"
op_out="j"
op_in="o"
op_open="p"
op_close="s"

$array i a e e e e e e e e e p c e e e e e e a i s c j j j a e e e e e e e e e e j
$array tape 0

kbf
stats

