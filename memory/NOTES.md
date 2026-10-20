# A net that dreams

A Hopfield network in one HTML file, `memory.html`: 1024 neurons on a 32×32
grid, a synapse between every pair. It stores pictures, recalls them from
damaged or partial cues, makes up false memories, and dreams to forget them.
Built 2026-10-19 in the playground's seventh thread. It is the first project
about memory, which is the one thing the threads here don't have.

Its first memories are the playground itself: one picture per thread (sand,
forth, terrarium, ripple, drum, snow, slime, a shell spiral for this one, a
speech bubble for `tongue/`, added by the eighth thread, a chimera for
`firefly/`, added by the ninth: a regular check on the left half, noise on the
right, and two barchans for `dune/`, added by the tenth). A later thread could
add its own sibling to `SIBLINGS`, then remeasure the numbers below. The 1982
numbers are for all eleven.

It is hard to tell siblings apart if they cut the same kind of shape out of
a white field. The speech bubble does that, like forth's screen, and still
recalls at 0.94 before any dreaming (just under the 0.95 bar).

What comes out of the maths:

- **A false memory nobody stored.** The siblings share a dark background, so
  under the plain 1982 Hebb rule every cue falls into one valley: the average
  of them all. It remembers 3 of 11: the balanced ones, forth, ripple and firefly.
  Firefly is half check and half noise, so it is nearly orthogonal to the
  rest and recalls perfectly from the start.
- **Dreaming fixes it** (Hopfield, Feinstein and Palmer 1983, and Crick and
  Mitchison's "we dream in order to forget" the same year). Settle from noise,
  then unlearn where it landed by `EPS` = 0.01 of a stored picture. Early
  dreams are all blends. By 125 dreams it remembers all 11 from a 20%
  damaged copy (6 at 100), and the dreams have become the siblings and their
  negatives. With ten siblings it had taken about 175.
- **Too much sleep is amnesia.** All 11 hold from 125 to 750 dreams. Then they
  go: 10 at 800, 9 at 900, 5 at 1000, 3 at 1100, 2 at 1200, none by 1250.
  After that, every cue settles to static at near-zero energy.
- **The capacity cliff.** Random pictures stored one at a time recall
  perfectly up to about 130, then fall apart at 0.138 N = 141, the
  Amit–Gutfreund–Sompolinsky limit. Dreaming rescues an overloaded net: at
  200 stored (α ≈ 0.2), recall from a 10% damaged copy goes from 0.48 to 0.98
  over 1400 dreams. At 256 stored it was too slow (0.80 after 2000), so the
  crowd stops at 200.
- **Negatives.** Energy is symmetric under flipping every cell, so each
  memory's negative is also a valley. Dreams land on negatives about as often
  as on the originals.
- **The 2020 rule is attention.** Ramsauer et al. (2020), after Krotov and
  Hopfield (2016): `x ← Xᵀ softmax(β X x)`, with the memories as keys and
  values and the cue as the query. With β·N above about 6 it snaps to the
  cued memory in 2–5 steps. Below about 5 it lands on a blur, and thresholded,
  that blur is the same false memory the 1982 net fell into (0.91 overlap in
  Node). Between 4 and 6 there's a blend that leans towards the cue (snow
  0.33, slime 0.19, terrarium 0.17). These 2020 numbers were measured with
  eight siblings, before tongue joined.

## Controls

Scenes 1–3: siblings, crowd, empty. Click a memory to cue it with 25% of its
cells flipped (recall starts), right-click to forget it. Drag on the grid to
draw, right-drag (or ctrl-drag) to rub out. Space recalls or pauses, `n`
flips 15% of the cells, `c` clears, `s` stores the grid, `d` dreams until
pressed again, `f` fast, `m` swaps the rule. The focus slider (2020 only) sets
β·N from 1 to 100 on a log scale.

## How the code works

- `W` is a symmetric Float32 N×N matrix with a zero diagonal. `imprint(p, k)`
  adds k/N · p pᵀ: k = 1 stores, −1 forgets, −EPS unlearns a dream.
- The fields `h = W s` are kept current: `flipAt()` updates them in O(N) per
  flip, so waking a neuron is O(1) and `isStable()` is an O(N) check. Anything
  that changes `W` sets `hStale`, and the fields are recomputed (O(N²)) at
  the next recall.
- `wake()` visits neurons from a reshuffled permutation (async updates).
  Recall wakes 32 a frame (all N when fast) and logs the energy, which only
  ever falls.
- Dreams run in their own arrays (`dS`, `dH`), one sweep a frame, giving up
  after 12 sweeps. Fast mode dreams for 14 ms a frame, about 7 ms a dream on
  the siblings.
- `describe()` names a state: a memory or its negative if an overlap reaches
  ±0.9, otherwise a blend of the up to three memories with |overlap| ≥ 0.3,
  otherwise "something it was never given".
- "Remembers k of K": `recallFrom()` on each memory (12 sampled when there are
  more than 16) from a copy with 20% of cells flipped (10% in the crowd),
  counted when the overlap comes back ≥ 0.95. Rerun after stores, forgets,
  rule swaps and every 10 dreams.
- 2020: `attend()` is one softmax step over all memories, with
  `focus` = β·N, so the logits are focus × overlap. Recall crossfades each
  step over 18 frames and stops when no cell moves by 1e-3, or after 8 steps.
  It has no `W` and nothing to dream away, so dreaming is off under it.
- The siblings are sign functions on [-1, 1]², rasterised by `raster()`. The
  drum is a real (2, 2) Bessel mode, and ripple is two point sources.

## Testing

Everything is a page global. `step()` advances one frame, then call `render()`
and `updateReadout()`. To settle a recall: `while (isRecalling) step()`. To
dream n: `actions.dream(); while (dreams < n) step(); actions.dream()`.
`scene(k)`, `cue(k)`, `setRule(r)`, `measureRemembers()` and `remembered` do
what they say. Sweeps were done first in Node with the same model code
(`imprint`, `settle`, overlap). The page writes no `localStorage`.

## Not done yet

- Temperature: a noisy (Boltzmann) update, so recall wanders between
  memories.
- Better learning rules (Storkey, pseudo-inverse) to set against dreaming.
  Dreaming is known to approach the pseudo-inverse rule.
- Sparse coding with a threshold, which is how real cortex would hold the
  siblings without dreaming.
- The crowd under the 2020 rule only goes to 200; it could take thousands.
