#!/bin/ksh

. ../kbf.sh

init

echo "Test underflow : 0 - 1 - 1"
$array tape 0
cell16 -1
cell16 -1
echo ${tape[$tptr]}

echo "Test underflow : 0 - 2"
$array tape 0
cell16 -2
echo ${tape[$tptr]}

echo "Test overflow : 65535 + 1 + 1"
$array tape 65535
cell16 1
cell16 1
echo ${tape[$tptr]}

echo "Test overflow : 65535 + 2"
$array tape 65535
cell16 2
echo ${tape[$tptr]}

