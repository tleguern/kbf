## kbf

The Korn shell BrainFuck interpreter

## Contents

1. [Synopsis](#synopsis)
2. [Install](#install)
3. [Tests](#tests)
4. [Contributing](#contributing)
5. [License](#license)

## Synopsis

    kbf [-dsD] [-c size] [-o optimisation] [-t size] [-O level] file[.b]

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

Through the switches -O and -o it is possible to enable some optimisation
strategies, such as optimised operators for some simple constructions and
[run length encoding](https://fr.wikipedia.org/wiki/Run-length_encoding).

The “bitwidth.b” torture test written by
[rdebath](https://github.com/rdebath/Brainfuck) works at every cell sizes
and optimisation levels :


| cell size |             Output |
| ----------|:------------------:|
|         8 |   Hello World! 255 |
|        16 | Hello world! 65535 |
|        24 |      Hello, world! |
|       32s |      Hello, world! |
|       32u |      Hello, world! |
|       64s |      Hello, world! |

kbf can be used directly or as a library.  The later can be useful to extend
the brainfuck language or implement variants such as Ook!  and blub (as
implemented in the `examples` directory).  The usage and behaviour of this
mode is described in the man page `kbf.3` while the executable command is
described in `kbf.1`.  It is possible to read them with either mandoc or
groff:

    $ mandoc kbf.1 | less
    $ groff -m mdoc -Tascii kbf.1 | less

A mandoc version of these man pages is also provided: [kbf.1.md](kbf.1.md) and [kbf.3.md](kbf.3.md).

## Install

### Requires

* Any a-bit-more-than-POSIX shell.

### Build

There is a makefile available for BSD systems, just run `make install`.
If you use something else just use `cp kbf.sh $DESTDIR/kbf`.

## Tests

Regression tests are available and documented in a dedicated [regress/README.md](README).

## Contributing

Either send [send GitHub pull requests](https://github.com/Aversiste/kbf) or [send patches on SourceHut](https://lists.sr.ht/~tleguern/misc).

## License

All the code is licensed under the ISC License.
