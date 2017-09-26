KBF(3) - Library Functions Manual (prm)

# NAME

**kbf** - Brainfuck interpreter written in Korn shell

# SYNOPSIS

**init**();

**kbf**();

**move**(*$index*);

**cell8**(*$value*);

**cell16**(*$value*);

**cell24**(*$value*);

**cell32s**(*$value*);

**cell32u**(*$value*);

**cell64s**(*$value*);

**output**();

**input**();

**nextzero**();

**prevzero**();

**stats**();

# DESCRIPTION

The
**init**()
function defines the global variables
*$instructions*,
*$tape*,
*$instidx*
and
*$tapeidx*,
which are respectively the
**Instructions Array**,
the
**Memory Tape**,
the
**Instruction Index**
and the
**Tape Index**.
It also defines two shorthands variables
*$array*
and
*$cell*
which respectively contains the name of either
**arrayksh**(),
**arraybash**()
or
**arrayzsh**()
and
**cell8**(),
**cell16**(),
**cell24**(),
**cell32s**(),
**cell32u**(),
or
**cell64s**().

The
**move**()
function moves the
**Tape pointer**
by the amount of bytes contained in
*$index*.
This number can be positive or negative. It is not possible to move
bellow the position zero or after the position
*$tflag*.

The
**cell8**(),
**cell16**(),
**cell24**(),
**cell32s**(),
**cell32u**(),
or
**cell64s**()
functions increase or decrease the value under the
**Tape Pointer**,
by the amount given as the parameter
*$value*.
This value can be positive or negative.  It is possible to give a large
value that will cause an overflow, also called wrap in Brainfuck
terminology.  Underflows are also possible.  The value at which a cell will
wrap depend on the function used.  The special value 0 is used to reset the
cell value directly at 0.

The
**output**()
function writes the
`ASCII`
representation of the byte under the
**Tape Pointer**.

The
**input**()
functions writes the value of the
`ASCII`
byte read from stdin in the
cell under the
**Tape Pointer**.

The
**nextzero**()
function moves the
**Tape Pointer**
to the next cell on the right with a value of zero. If none are found,
it moves it to the end of the
**Memory Tape**.

The
**prevzero**()
function moves the
**Tape Pointer**
to the next cell on the left with a value of zero. If none are found,
it moves it to the beginning of the
**Memory Tape**.

The
**stats**()
function writes statistics about the programme, such as the number of
cells used, the number of instructions executed and the state of the
**Memory Tape**.

The
**kbf**()
function executes the instructions contained in the
**Instructions Array**
with the help of the
**Instructions Pointer**.

# INTERMEDIARY REPRESENTATION

The
**kbf**
utility is able to transform some parts of the programme into new operators,
for performance purpose :

0

> Replace the clear loop, \[-].

&gt;&gt;

> Replace the next zero loop, \[&gt;].

&lt;&lt;

> Replace the prev zero loop, \[&lt;].

# EXAMPLES

This example runs a simple multiplication loop on a
**Memory Tape**
already initialized:

	. ./kbf.sh
	
	init
	$array instructions "+ + + [ > + + + < - ]"
	$array tape 5 2
	kbf
	stats

# SEE ALSO

kbf(1)

# AUTHORS

The
**kbf**
utility was written by
Tristan Le Guern &lt;[tleguern@bouledef.eu](mailto:tleguern@bouledef.eu)&gt;.

Linux 4.9.0-3-amd64 - January 18, 2015
