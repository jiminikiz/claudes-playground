# Spiral soup

A dish of self-copying molecules in one HTML file, `soup.html`: a hypercycle
on a 300×300 torus, after Boerlijst and Hogeweg. Built 2026-10-20 in the
playground's twelfth thread. It is the first project about the origin of
life, and the second about evolution (after `terrarium/`), here acting on
something bigger than the things that copy.

The rule is table 1 of Boerlijst & Hogeweg, "Spiral wave structure in
pre-biotic evolution: hypercycles stable against parasites", Physica D 48
(1991) 17–28, with their parameters. A cell is empty or holds one molecule.
Each step, synchronously: a molecule decays with chance 0.2; an empty cell
is filled from one of its four neighbours, each with a claim of
`self` (1) plus `c[x, y]` (100) for every catalyst y among the four cells
flanking the line of copying, against a claim of 11 to stay empty. Kind i is
catalysed by kind i−1 (and 1 by n). Then two Toffoli–Margolus diffusion
passes: every 2×2 block turns a quarter turn either way, the partition
shifting one cell diagonally each pass. The parasite gets `c = 200` from
kind 2 and gives nothing. The mutant strain in scene 5 is kind 1 with its
own decay. The paper's PDF is at tbb.bio.uu.nl/pdf/Boerlijst.pd91-48.pdf;
the second source, their Artificial Life II chapter "Self-structuring and
selection: spiral waves as a substrate for prebiotic evolution" (1991,
pp. 255–276), is at tbb.bio.uu.nl/pdf/Boerlijst.alII91.pdf and is a scan
with no text layer: render the pages and read them as images.

What comes out of it (measured in Node with the same rule, then in the
page, which matches the Node rule cell for cell):

- **Spirals, in couples.** Nine kinds at random, half the cells empty:
  spirals by step 500, settled by 1500, 4 to 8 pairs on the dish. The
  winding-number count always finds as many turning one way as the other,
  which a torus demands.
- **The period matches the paper.** Measured from the unwrapped phase at
  sampled points: 112–113 steps a turn for nine kinds (paper: about 110),
  77.6–78.4 for six (paper: 76). It grows with the cycle about as their
  Fig. 5(d) shows: 65, 78, 89, 112, 148 steps for 5, 6, 7, 9, 12 kinds.
- **Fewer than five kinds, no spirals.** Three kinds mix finely (thousands
  of phase defects, no structure). Four kinds churn: 50–120 wave centres,
  of which only about a third are still there 60 steps later, against all
  of them for nine kinds. Five kinds make spirals (14–20 centres, 66 steps a
  turn), though they wander: a third to three quarters of centres are
  within 8 cells of where they were 60 steps before. The paper says at
  least five members for stable spirals.
- **Parasites are swept out.** A hundred parasites dropped at random on
  grown nine-kind spirals. Ten seeds: all gone in four (three within 160
  steps, as in the paper's Plate 3); in six, one reached a spiral centre and
  stayed as a cyst of 500–1700 that never spread. The cycle lived in all ten.
  Five earlier seeds: two cleared within 160, three cysts, one of those
  cleared by 2000. Stronger parasites, three seeds each: decay 0.1 kills the
  cycle every time (paper: fatal at ≤ 0.1); decay 0.15, self 2 or support
  500 never do, though they often leave cysts (paper: none can destroy it). With 3, 4 or 5
  kinds the parasite wins; with 6 the cycle survives alongside big cysts.
- **Stirring kills it, and stirring a little doesn't.** A perfectly stirred
  pot (every cell shuffled every step) of grown nine-kind spirals breaks
  within 50–71 steps (ten seeds): the kinds boom and bust in turn and one
  runs out. From a random start it dies by step 200 and one kind is left
  copying itself unhelped at 35% of the dish. Three kinds in the pot sit at
  27% each; four swing between 1% and 60% and survive 1500 steps. That is the
  ODE picture (a stable point for n ≤ 4, a limit cycle for n ≥ 5), plus the
  finite pot letting a trough hit zero. On the dish, more stirring makes
  bigger spirals: 18–21 pairs with none, 4–8 with 2 passes, 1–7 with 16.
- **Breeders.** In the page's breeders scene (six kinds, seed 16), the 256
  molecules within 10 cells of a spiral centre, dyed red, become 3697 by
  step 100 and 4104 by 200; the 8803 dyed blue within 60 cells fall to 2166.
  Red then holds at 2000–3500 to step 2400. A patch dyed at a centre grows
  (90 to 1840 in 200 steps); the same patch 47 cells from the nearest centre
  is gone in 50. This is the paper's Plate 2.
- **How big the breeding ground is.** Dye every molecule within r of every
  spiral centre, all one colour, and follow its share of all molecules.
  Nine kinds (seed 14, 8 centres): r = 6 levels off at 25%, r = 10 at 70%,
  r = 15 at 92%, r = 20 reaches 100% by step 140. Six kinds (seed 16, 10
  centres): 87% at r = 10, 97% at 15, 98–99% at 20, 100% at 30 by step 190.
  So a nine-kind spiral is bred from the molecules within about 20 cells of
  its centre, about a ninth of the dish between them. Below that the share
  stops rising: the dyed and undyed breeders drift side by side.
- **Fragile beats sturdy.** Changing kind 1's decay on grown six-kind
  spirals sets their period, as in the ALife II chapter's Fig. 5(a): 109
  steps at decay 0.05, 89 at 0.1, 82.5 at 0.15, 78 at 0.2, 75 at 0.25, then a
  floor of 71–75 from 0.3 to 0.75. So a strain of kind 1 that falls apart
  faster makes its spirals turn faster. Two strains, kind 1 on the left half
  replaced by a mutant, run to 6000 steps (share of kind 1 at the end):

  | mutant decay | runs | mean share | lost (< 0.1) | fixed (> 0.9) |
  | ------------ | ---- | ---------- | ------------ | ------------- |
  | 0.15         | 15   | 0.38       | 3            | 3             |
  | 0.2 (same)   | 15   | 0.43       | 1            | 1             |
  | 0.3          | 25   | 0.75       | 1            | 4             |

  Three runs of each ran 8000 steps; the 0.3 row adds ten more seeds. In
  Eigen's equations the sturdier strain wins. Here the fragile one does, on
  average, because spirals compete and the faster one pushes the boundary
  back. At decay 0.1 the mutant took all of kind 1 in all three half-dish
  runs, and in all four planted in a centre (0.1 and 0.13): sturdy enough to
  live in every spiral's centre (the chapter's rule A, ≤ 0.13).

## What didn't work

**"No diffusion makes the parasite fatal."** The paper says the parasite of
Plate 3 is fatal without diffusion. Not here: with diffusion off from the
start, the parasites died out in 3 of 3 runs (by 1000–3000 steps); with it
switched off at infection, the cycle survived in 6 of 6 (cleared in four,
lingering at 68–81 molecules in two). Without diffusion they linger longer,
nothing more. Unknown which detail differs.

**The chapter's planted mutant.** The chapter replaced kind 1 in one
spiral's centre with a mutant and counted after 4000 steps. Here even a
neutral mutant planted that way was lost within 1000 steps (6 of 6 at
radius 10, 3 of 3 at radius 35), and so were most fragile ones (0.3 won once
in three). Watching one run: the centre picked was one of a close pair, and
kind 1 from the partner spiral reseeded it within 160 steps. Dyeing only
kind 1 at a centre shows why: that line usually grows to about 1000 in
100–200 steps, then is gone by step 1000 in 9 of 12 runs. The breeders of one kind
are few and turn over, so a planted mutant mostly drifts out before spiral
selection can act. Giving each strain half the dish, with several spirals
each, is the scene that shows the effect.

**A test for lasting spirals.** Counting centres still within 8 cells after
60 steps didn't separate four kinds (a third last) from five (a third to
three quarters), because five-kind spirals wander. The readout uses the
paper's rule instead: four kinds or fewer, no lasting spirals.

## Controls

Scenes 1–5: spirals, parasites, stirred, breeders, two strains. Scenes 2–5
grow a soup first (1500 steps for nine kinds, 2000 for six; about 6–8 s at
full speed), then cache it, so going back is instant. One knob per scene:

- Spirals: kinds in the cycle, 3–12 (restarts).
- Parasites: how fast the parasite falls apart, 0.05–0.4, live.
- Stirred: stirring, 0 to 32 Margolus passes a step or a full shuffle, live.
- Breeders: none.
- Two strains: how fast the white strain falls apart, 0.05–0.6 (restarts
  from the cached soup).

The pointer: `p` parasites, `s` stir (shuffles a disc), `d` dye (each stroke
a new colour, copies inherit it), `w` wipe. Space pauses, `r` starts again,
`f` is fast, `v` changes the view (kinds, dye, and strains in scene 5).

Hidden: if one stroke of dye that marked under half the molecules comes to
be carried by 99% of them, a note appears naming it a last universal common
ancestor. Doing it means finding the breeders: scribble over every spiral's
centre, about 20 cells round, without lifting. Tested in the page with one
synthetic stroke: 13% dyed, 100% after 136 steps. The owner asked for
Easter eggs in `CLAUDE.md` on 2026-10-20.

## How the code works

- `Soup(W, H, seed)` holds everything: `a` (kinds, Uint8), `la` (dye,
  Uint16, copied with each molecule and moved with it), `decay`, `self` and
  `cat` (16×16, `cat[x*16+y]` is the help x gets from y). Codes: 0 empty,
  1..n kinds, `MUT` 14, `PAR` 15. `setCycle(n, opts)` writes the tables.
- `step()` is the rule, synchronous into `b`, then `stir` Margolus passes,
  or `shuffle()` when `stir` is −1. The xorshift generator is inlined in
  `step()` and `margolus()` but draws in the same order as `rnd()`: one
  draw per cell, one per block. That is what lets a seed replay exactly.
- `grow(n, seed, steps, then)` caches `{a, rng, mo, t}` per `n/seed`; the
  scenes use seed 14 (nine kinds) and 16 (six).
- `cores()` smooths the phase (kind i at angle 2π(i−1)/n) over 7×7 and
  finds plaquettes with winding ±1. The readout calls it every 60 steps.
- `tracker` unwraps the 7×7 phase at 240 random points over 240 steps;
  the period is the median.
- Drawing: each cell is the mean colour of the molecules in its 3×3 block,
  with a quarter of its own colour back in; any parasite in the block marks
  it, as the paper's plates did. Colours are OKLCH, L 0.72, C 0.15, hues
  round the wheel so kind n sits next to kind 1.
- `ancestors` maps a dye label to its share when its stroke ended (only
  strokes under 50% are watched); `checkAncestors()` runs with the strip
  and shows `#egg` once.
- The strip stacks the counts every few steps (`stripEvery`: 1 in the
  stirred scene, 10 for the strains, 4 otherwise).

## Speed

In Brave: `step()` 3.1 ms at 300², `render()` 4 ms, `cores()` 15 ms. Two
steps a frame normally (about one turn of a nine-kind spiral a second); fast
runs steps for 30 ms a frame. Hoisting the arrays and inlining the generator
took `step()` from 8.6 ms to 3.1.

## Testing

Everything is a page global. Set `isPaused = true`, then `advance(n)`,
`render()`, `updateReadout()`. To get past a growth: `chooseScene(SCENES[k]);
while (growing && S.t < growing.until) tick(); finishGrowing();`. Chunks of
2000 steps per `javascript_tool` call are safe. The sweeps used a Node copy
of `Soup` and a montage writer; the page's `Soup` can be pulled out of the
HTML with `new Function` for the same. The page writes no `localStorage` and
makes no sound. `memory/` has soup's sibling: a spiral couple.

## Not done yet

- Shortcut mutants (the ALife II chapter, §3.3.1): a mutant that skips a
  kind makes a shorter cycle, which turns faster and wins. A 7-cycle becomes
  a 6. But a 6 shortened to a 5 left kind 1 as a parasite on the new cycle,
  and it died: evolution walks the cycle into a trap. Worth reproducing.
- Mutation on every copy, so strains arise rather than being planted, and
  the giving of help evolves.
- Eigen's error threshold, the reason hypercycles were proposed: a copier
  of length L survives only if its error rate is under about ln(σ)/L.
- Boerlijst and Hogeweg (1995): a gradient in decay makes spirals drift and
  holds off even strong parasites.
