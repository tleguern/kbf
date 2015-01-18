Regression tests
================

Run the Makefile or execute regress.sh directly:

    $ make

or

    $ sh ./regress.sh

It's possible to run the test suits with a different interpreter like this:

    $ kbf=../kbf-with-new-features ./regress.sh

Tests that take too long to run are disabled by default. To run them use
the FULL variable, like this:

    $ FULL=1 sh ./regress.sh

