kbf - the Korn shell BrainFuck interpreter
==========================================

    kbf [-dsD] [-c size] [-o optimization] [-t size] [-O level] file[.b]

kbf is a brainfuck interpreter written in korn shell. It is currently
compatible with multiple shells, not just bash, and thus is probably the
most portable implementation. The following shells are supported:

- Public Domain Korn SHell - pdksh;
- OpenBSD Korn SHell - oksh;
- MirBSD Korn SHell - mksh;
- GNU Bourne-Again SHell - bash;
- The Z shell - zsh.

Other shells might be supported in the future in they handle extension
to POSIX such as local variables and arrays. This implementation works
with various cell sizes from 8 to 64 bits but default to 24 as it is the
largest size handled by all supported shells.

Throught the switches -O and -o it is possible to enable some optimization
strategies, such as optimized operators for some simple constructions and
[run length encoding](https://fr.wikipedia.org/wiki/Run-length_encoding).

The “bitwidth.b” torture test written by
[rdebath](https://github.com/rdebath/Brainfuck) works at every cell sizes
and optimization levels :


| cell size |             Output |
| ----------|:------------------:|
|         8 |   Hello World! 255 |
|        16 | Hello world! 65535 |
|        24 |      Hello, world! |
|       32s |      Hello, world! |
|       32u |      Hello, world! |
|       64s |      Hello, world! |

kbf can also be used as a library in order to implement extension or
variants, such as Ook! or Blub (both implemented in the `examples/`
directory).

kbf can be used directly or as a library. The later can be useful to extend
the brainfuck language or implement variants such as Ook! and blub. The
usage and behaviour of this mode is described in the man page `kbf.3`
while the executable command is described in `kbf.1`. It is possible to
read them with either mandoc or groff:

    $ mandoc kbf.1 | less
    $ groff -m mdoc -Tascii kbf.1 | less

Installation
------------

There is a Makefile available for BSD systems, just run `make install`.
If you use something else just use `cp kbf.sh $DESTDIR/kbf`.

