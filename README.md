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
