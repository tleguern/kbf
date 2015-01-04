kbf - the Korn shell BrainFuck interpreter
==========================================

kbf is a brainfuck interpreter written in korn shell. It is currently
compatible with OpenBSD pdksh and bash.

Some details about this implementation:

- Lazy-initialized cells;
- No memory wrapping;
- No negative cell number;
- Fixed number of cells (default to 1000);
- Newline is 10;

Installation
------------

There is a Makefile available for BSD systems, just run `make install`.
If you use something else just use `cp kbf.sh $DESTDIR/kbf`.

Regression tests
----------------

Go in the `regress` directory and run the Makefile. You can also run
regress.sh directly to see the output.

    $ cd regress
    $ make

or

    $ cd regress
    $ sh ./regress.sh

It's possible to run the test suits with a different interpreter like this:

    $ kbf=../kbf-with-new-features ./regress.sh

Tests that take too long to run are disabled by default. To run them use
the FULL variable, like this:

    $ FULL=1 sh ./regress.sh

