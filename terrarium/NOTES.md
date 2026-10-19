# Terrarium

A soil-and-rain world in one HTML file, `terrarium.html`, where the bugs'
brains are small Forth programs. Children inherit the parent's brain, one in
eight with a mutation, so species evolve. The inspector shows an evolved brain
as a diff against its original, and the log records lineages that take hold
and die out. Built 2026-10-19 in the playground's second thread, on top of
`sand/` (the world) and `forth/` (the language).

## The world

240×120 cells. Codes are also what a brain's senses push.

| Code | Material | Behaviour                                                              |
| ---- | -------- | ---------------------------------------------------------------------- |
| 0    | air      |                                                                        |
| 1    | dirt     | Static. Holds moisture in `life` (cap 12); seeps downhill, dries at air. |
| 2    | sand     | Powder.                                                                |
| 3    | stone    | Static. Off-grid reads as stone, so the edges are climbable walls.     |
| 4    | water    | Liquid. Soaks into dirt below it; evaporates slowly at the surface.   |
| 5    | plant    | A stem. Edible. Lives on water its neighbours pass along.             |
| 6    | seed     | Powder. Sprouts into a root on damp dirt; rots after 900 ticks.        |
| 7    | bug      |                                                                        |
| 8    | husk     | A dead bug. Powder; turns to dirt after 400 ticks at rest.             |
| 9    | root     | A plant cell on dirt. Not edible. The only part that drinks.           |

Rain drops water along the top row. It is the knob that sets how many bugs the
world can carry: light rain (0.4 drops a tick) holds about 25–60.

## Bugs

- One cell each, in `bugs[]`, with `who[i]` = index + 1 on their grid cell.
  `swap()` keeps `b.i` in step; `removeBug()` swap-pops and fixes `who`.
  Bugs are stepped backwards so swap-pop and births never skip or repeat one.
- Each tick: age, hunger (1 per 4 ticks, 1 more when water is above), death
  check (husk), gravity unless gripping a side wall, then `think()`.
- `think()` runs `brain` from the top with an empty stack until the first
  action or 200 steps. Popping empty gives 0. Only the four `mem` cells persist.
  That makes every program safe to run, which is what lets mutation be blind.
- A brain compiles to one `Int32Array` of `[op, arg]` pairs per definition
  (`LIT PRIM CALL JZ JMP ACT RET`). Calls use an explicit return stack, not JS
  recursion; a name can be called before it is defined. This VM is separate
  from Little Forth's: that one recurses in JS and can't stop mid-word.
- `split` needs 100 energy, costs 40, and gives the child half of what's left.
  `eat` takes a touching plant (20) or seed (10) first; otherwise a bug ahead,
  1 time in 4, for a third of its energy.

## Species and mutation

- A species is one exact token list (`registry`, keyed by the joined tokens).
  Comments are stripped by `tokenize`, so only originals keep them.
- `mutate()` never touches control words or definition names, so a mutant
  always compiles. Edits: swap a word for one of its class (`CLASSES`), nudge a
  number, delete, insert, duplicate, or (1 in 10) drop in a whole
  `<sense> <thing> = if <action> then` rule at a line start.
- A mutant's hue drifts ±25° from its parent's, so a lineage stays one colour
  family.
- `diff()` is a token LCS. `layout()` puts one rule per line. `changes()` gives
  the one-line summary used in the log ("took hold" at 6 alive).
- The editor only registers a species when a bug first runs it, so typing
  doesn't fill the list.

## Tuning that mattered

Each of these was a world where everything died:

- Plants were touch-the-water-only and rain rarely hit them. Soil moisture fixed
  it: rain soaks in, spreads, and roots drink from it.
- Grazers ate plants at the base and nothing grew back. Roots fixed it: they
  can't be eaten, and regrow stems.
- Bugs split the moment they could, boomed to 600 and starved together. The
  presets now split at 250, plants are worth 20, and a split costs 40. The
  threshold is a number in the brain, so evolution can still move it. Mutants
  that halve it show up and take hold, then die out.
- Deleting one word (`plant`) from `ahead plant = if eat then` makes a bug that
  eats whoever is in front of it. At half the prey's energy with no escape,
  predators wiped out every run. Now a catch works 1 time in 4 for a third.
- Stems drank rain directly, so canopies whose stems were grazed away floated
  on forever, out of reach, and held most of the plants. Only roots drink now;
  a cut-off canopy dries, withers, and drops some seeds.
- Without mutation the grazer settles near 25 on a grazed lawn. With it, the
  world has stayed alive in every 12,000-tick run tried, at 0.14 ms a tick.

## Testing

`step()`, `scene()`, `release()`, `bugs`, `registry` and `offspring` are page
globals. Pause with `setPaused(true)`, step thousands of ticks from
`javascript_tool`, then `render(); drawSpecies(); drawChart()`. Replacing
`offspring` with `sp => sp` turns mutation off for an A/B. The page writes no
`localStorage`.

## Not done yet

- A sense for the cell diagonally up-ahead, so a brain could tell a step from
  a wall without trying to walk.
- Save a species (or the whole world) and load it back. A token list is
  already a string.
- Fire from the sand toy: a dry spell plus lightning would make a disturbance
  that resets the plants.
- Sexual recombination: two parents' token lists spliced at a shared `then`.
