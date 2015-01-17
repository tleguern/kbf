kbf - the Korn shell BrainFuck interpreter
==========================================

kbf is a brainfuck interpreter written in korn shell. It is currently
compatible with the following shells:

- Public Domain Korn SHell - pdksh;
- OpenBSD pdksh;
- MirBSD Korn Shell (mksh);
- bash.

Some details about this implementation:

- Lazy-initialized cells;
- Support for 8, 16 and 32 bits cells;
- Memory wrapping for 8 and 16 bits cells;
- No negative cell number, except with 32 bits cells;
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

