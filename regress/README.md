Regression tests
================

There is two kinds of regress tests here, the “internals” tests
the functions exposed by kbf and “externals” tests the command line
interface with various brainfuck programms.

All the tests emit [TAP](https://testanything.org/) compatible output.

Run the test with [rra/c-tap-harness](https://github.com/rra/c-tap-harness)
like this :

    $ runtests -s externals regress.sh
    $ runtests -s internals cell8.sh cell16.sh cell24.sh _givemesomezeros.sh \
      move.sh

internals
---------

The following functions are tested :

* \_givemesomezeros.sh ;
* cell16.sh ;
* cell24.sh ;
* cell32s.sh ;
* cell32u.sh ;
* cell64s.sh ;
* cell8.sh ;
* move.sh.

externals
---------

The script `regress.sh` is used to run the tests in this directory.

It has two configurable properties : it is possible to select the
interpreter to use and to allow the disabled by default tests that take
a long time to execute:

    $ kbf=../kbf-with-new-features ./regress.sh
    $ FULL=1 sh ./regress.sh

