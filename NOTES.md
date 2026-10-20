# The relay (index.html)

The playground's landing page, built 2026-10-20 by the thirteenth thread. One
shared 192 × 120 canvas; each sibling runs a small copy of its project's own
rule on it, starting from whatever matter (`M`, one number per cell, 0 to 1)
the sibling before it left. When idle it hands itself on in lineage order;
after soup it goes back to sand. The nav icons are `memory/`'s pictures, and
the memory sibling recalls one of them from the canvas (2020 rule, attention,
with mean-centred keys so sparse cues don't all fall into the sparsest one).

## State

Working: sand, forth (Life written in a mini Forth; type in the box),
ripple (glass with dispersion, energy view), drum (`drum/`'s solver on the
biggest patch, Chladni sand, sound on click), snow (Gravner–Griffeath on a
2× hex lattice), slime (Tero), memory, firefly, dune (Werner), tune
(Sethares; columns become overtones; sound on click), soup (Boerlijst–Hogeweg
at 384 × 240).

**Not built yet: terrarium and tongue** are `stub()`s that only show the
matter. Planned: terrarium = soil from matter, rain, plants, bugs with
rule-list brains that mutate on splitting; tongue = serial reproduction, each
generation a fresh small coordinate MLP trained on a random half of the last
picture, thresholded to keep the lit fraction (the "wants to be understood"
pressure).

## Known problems

- Slime is slow: about 20 ms a tick in Node on a loaded machine (CG over
  ~1600 nodes, ~10k links). It is time-budgeted, so it thins slowly. Fewer
  links, or fewer CG iterations, would help.
- Drum's solve takes 0.5–1 s for a big skin on a slow machine (it is
  deferred with setTimeout so a frame paints first). KRYLOV could drop.
- Snow deviates from the paper on purpose: the rim reflects and every air
  site is fed 0.0006 of the way back to ρ each step. With the paper's fixed
  far field, ice touching the rim raced along it.
- Dune wraps east–west only; slopes stop at the top and bottom edges.
- Timings in this thread were taken on a machine running about 2× slow.

## Testing

`<script id="rules">` has no DOM at top level. Pull it into Node with
`new Function(src + 'return {…}')` (set `drum.isDeferred = false`), as the
thirteenth thread's harness did. In the page: `setRelay(false)`, `handTo(SIBS[k])`,
then call `SIBS[k].rule.step()` n times and `.draw(ctx)`. `fade = null`
clears the crossfade before a screenshot. The page writes no `localStorage`.

## Adding a sibling

Write a rule object (`from(m)`, `to(m)`, `step()`, `draw(ctx)`, optional
`poke(p)` and `status()`), add an entry to `SIBS` with its thread, hue,
dwell, lines and card text, and add its picture to `PICTURES` (and to
`memory/`'s `SIBLINGS`). The dashed "next" slot is its place; a hidden
memory of that slot's "?" lights it if someone draws a question mark for the
memory sibling.
