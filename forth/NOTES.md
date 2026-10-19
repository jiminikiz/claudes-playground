# Little Forth

A small Forth in one HTML file, `forth.html`: a REPL with a live stack readout
and a 64×64 pixel screen. Built 2026-10-19, right after the sand toy.

## What's in it

- Integers only, 32-bit (`| 0` on every push). True is -1.
- Arithmetic, comparison, bitwise and stack words; `>r r> r@ i j`.
- `: ;`, `recurse`, `exit`, `if else then`, `begin until again while repeat`,
  `do loop +loop leave`. These only work inside a definition.
- `variable constant create allot , here ! @ +!` over a flat cell array. One
  cell is one address, so `cells` does nothing.
- `( )`, `\`, `."`, `.(`, `char`, `words`, `.s`.
- Screen: `cls`, `plot ( x y c -- )` with a 16-colour palette, `rnd ( n -- r )`.
- Examples live in `EXAMPLES` and run through the same `enter()` you type into.

## How the code works

- A colon definition compiles to an array of ops: `call lit jmp jz str do loop
  leave exit`. `run()` is the inner interpreter.
- Calls recurse in JS. The Forth return stack holds only loop parameters and
  `>r` values, and `exit` trims it back to the frame's base.
- Control words push markers onto `compiling.cs` and patch jump targets when
  the structure closes. Mismatches error at compile time.
- `+loop` ends when `index - limit` changes sign, which covers negative steps.
- Guards: 5 million steps and 1000 call depth, so `begin again` and runaway
  `recurse` give an error instead of freezing the tab.
- An error clears both stacks and abandons any half-finished definition, as
  gforth does.
- Globals are named `say`, `gfx`, `past` so they don't shadow `window.print`,
  `window.screen` and `window.history`.

## Not done yet

- `does>`, which would make `create` useful for real data structures.
- Strings beyond `."` (`s"`, `type`).
- `see` to decompile a word back to source.
- `key` or an animation word, so a program could loop over frames. It would
  need `run()` to yield to the browser.
