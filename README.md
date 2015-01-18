kbf - the Korn shell BrainFuck interpreter
==========================================

kbf is a brainfuck interpreter written in korn shell. It is currently
compatible with the following shells:

- Public Domain Korn SHell - pdksh;
- OpenBSD Korn SHell - oksh
- MirBSD Korn SHell - mksh;
- GNU Bourne-Again SHell - bash;
- The Z shell - zsh.

Some details about this implementation:

- Lazy-initialized cells;
- Support for 8, 16 and 32 bits cells;
- Memory wrapping;
- No negative cell number;
- Fixed number of cells (default to 1000);
- Newline is 10;

kbf can be used directly or as a library. The usage and behaviour of 
these two modes are described in there corresponding man pages: kbf.1 
and kbf.3. It is possible to read them on any good systems like this:

    $ mandoc kbf.1 | less

Installation
------------

There is a Makefile available for BSD systems, just run `make install`.
If you use something else just use `cp kbf.sh $DESTDIR/kbf`.

