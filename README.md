kbf - ksh brainfuck interpreter
===============================

kbf is a brainfuck interpreter written in ksh.

Some details about this implementation:

- Lazy-initialized cells;
- No memory wrapping;
- No negative cell number;
- Fixed number of cells (default to 1000);
- Newline is 10;
