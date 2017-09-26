KBF(1) - General Commands Manual (urm)

# NAME

**kbf** - Brainfuck interpreter written in Korn shell

# SYNOPSIS

**kbf**
\[**-dsD**]
\[**-c**&nbsp;**size**]
\[**-o**&nbsp;**optimisation**]
\[**-t**&nbsp;**size**]
\[**-O**&nbsp;**level**]
*file\[.b]*

# DESCRIPTION

The
**kbf**
utility interprets the Brainfuck programming language. It only
recognises the 8 classics operators: + &#45; &lt; &gt; \[ ] , .

It is not allowed to move beyond the limitation of the tape, but it is allowed to increment beyond the cells upper limit and to decrement a zero cell. In these cases the value will wrap, depending on the option
**-c**.

The output operator '.' prints the value 10 as a newline.

The arguments are as follows:

**-d**

> Enable debug mode. This will print the executed instruction, the cell
> number and the cell value.

**-s**

> Print information about the programme after execution. This include the
> number of cell used, the number of instruction executed and a dump of
> the memory tape.

**-D**

> Print the intermediary representation of the programme and quit.

**-c**

> Allow to choose the size of the cells, in bits. Accepted values are 8,
> 16, 24, 32s, 32u and 64s. The values 32s and 64s uses
> signed integers while 8, 16, 24 and 32u are unsigned.  The default is 24, as
> it will work with all the shells.

**-o**

> Select a specific optimisation to apply, it is possible to use this option
> multiple times.  The allowed values are :

> strip-comments

> > Remove every comments, spaces and new lines in the programme.

> strip-null-operations

> > Remove null actions, like a substraction following an addition.

> optimised-operands

> > Replace some some simple but costly constructions with faster operators.
> > Currently implemented are the clear loop \[-], the next-zero \[&gt;] and
> > previous-zero \[&lt;].

> run-length-encoding

> > Compress consecutive, similar operators for faster execution.

**-t**

> Allow to choose the size of the tape. The default is 1000.

**-O**

> Allow to choose the optimisation level. Accepted values are 0, 1,
> 2, 3 and 4. The default is 1.

> 0

> > Disable all optimisation.

> 1

> > Toggle strip-comment.

> 2

> > Also toggle strip-null-operations.

> 3

> > Also toggle optimised-operands.

> 4

> > Also toggle run-length-encoding.

# EXIT STATUS

The **kbf** utility exits&#160;0 on success, and&#160;&gt;0 if an error occurs.

# SEE ALSO

ksh(1),
kbf(3)

# AUTHORS

The
**kbf**
utility was written by
Tristan Le Guern &lt;[tleguern@bouledef.eu](mailto:tleguern@bouledef.eu)&gt;.

Linux 4.9.0-3-amd64 - November 9, 2016
