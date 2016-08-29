#!/bin/ksh

. ../kbf.sh

init

echo "Test underflow : 0 - 1 - 1"
$array tape 0
cell8 -1
cell8 -1
echo ${tape[$tptr]}

echo "Test underflow : 0 - 2"
$array tape 0
cell8 -2
echo ${tape[$tptr]}

echo "Test overflow : 255 + 1 + 1"
$array tape 255
cell8 1
cell8 1
echo ${tape[$tptr]}

echo "Test overflow : 255 + 2"
$array tape 255
cell8 2
echo ${tape[$tptr]}

