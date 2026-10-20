# Dune field

A desert in one HTML file, `dune.html`: sand on a 300×300 torus of bare
gravel, moved by wind one slab at a time. Built 2026-10-20 in the
playground's tenth thread. It is the first project about landscape, and the
second (after `sand/`) about sand, at a scale where a grain is a slab and a
dune is the thing that moves.

The rule is Werner's (Geology 23, 1995, p. 1107), with his parameters: a
random cell gives up a slab unless it is bare or in a wind shadow; the slab
hops l = 5 cells downwind until it sticks, with probability 0.6 on sand and
0.4 on bare ground, and always in a shadow (under a 15° line from anything
upwind). Slabs are a third of a cell thick. Nowhere may be steeper than
2 slabs a cell (about 34°); oversteep sand slides. Nothing in the rule knows
what a dune is.

What comes out of it (measured in Node with the same rule, then seen in the
page):

- **Barchans, horns downwind.** One wind and 1.5 slabs a cell: by t ≈ 150
  the sand has gathered into crescents. At 3 slabs they form and then link
  into one wavy ridge by t ≈ 800 (on 200²). At 8 and 15 slabs it goes
  straight to transverse ridges. This is Werner's barchan-to-crescentic
  sequence with sand supply.
- **Small dunes run faster, but not as 1/H.** Barchan fields at 1.5 slabs,
  300², three seeds, every dune tracked from t = 300 to 900 (about 3,500
  matched pairs). Speed falls from 0.85 cells per unit at 6 slabs tall to
  0.35 at 27. Speed × height is not constant: it climbs from 5 to 9.5. It
  fits c = Q/(H + H₀) with H₀ ≈ 5 slabs, Q ≈ 11 (a power law gives
  c ∝ H^−0.6 to −0.7). Bagnold's c = q/H with an offset. Whether real
  barchans need the same offset wasn't looked up.
- **Two winds: the crests flip at about 90°.** Winds at ±θ/2 about west,
  taking turns every 40 time units (Werner's Δt), 5 slabs a cell, 200²,
  t = 2000, three seeds each. Crest angle from the structure tensor of the
  slope:

  | angle between winds  | 62° | 74° | 77° | 80° | 90° | 100° | 103° |
  | -------------------- | --- | --- | --- | --- | --- | ---- | ---- |
  | across the mean wind | 2   | 3   | 2   | 2   | 1   | 2    | 0    |
  | along it             | 0   | 0   | 0   | 1   | 2   | 0    | 3    |
  | no clear direction   | 1   | 0   | 1   | 0   | 0   | 1    | 0    |

  "No clear direction" is coherence under 0.25. A first pass at t = 1200
  had 16° and 32° across, 113°, 134°, 148° and 164° along.
  Rubin and Hunter's rule (1987) says the flip is at exactly 90° for equal
  winds; Werner's Fig. 5 found it near 90° and saw hints of both answers
  near the flip. Here too: from 80° to 100° either can win.
- **Cross-bedding.** Every slab remembers when it came to rest. Cut through
  a barchan and its inside is layers leaning downwind at the angle of
  repose: each was the slip face for a moment. Nobody put them there.
- **Climbing sets, a sandstone.** With sand settling out of the air
  (0.1 slabs a cell per unit) on 4 slabs of ridges, the floor rises, each
  dune climbs over the last one's base, and the cut keeps sets of
  cross-beds stacked under the living dune, each era in its own tint,
  truncated where the next dune scoured.
- **Plants turn a barchan inside out, if they grow on the plain.** Scrub
  grows `G` a season, dies by erosion (0.3 a slab) and by burial past
  1 slab a season (0.1 a slab). It holds sand down and traps it. Scrub on
  the plain catches the thin horns; the body runs on and leaves them drawn
  out as long arms trailing upwind (the hairpin parabolic dune of Nield and
  Baas). With scrub allowed only on sand, the barchans stay barchans: the
  plants just fill the lee hollow. So in this model it is the dune running
  into vegetated ground that does it.

## What didn't work

**Star dunes.** Werner's Fig. 3C made star-like dunes from four winds at
right angles, 80 units each, 15 slabs a cell. Here that gives a network of
ridges at 15 and at 8 slabs (t = 1600, 200²), not stars. Isolated piles
under four (or three) turning winds gave squat domes (fast turns, Δt 10) or
wandering crescents (Δt 40). So the four-winds scene was replaced by the
sandstone one. Unknown whether the difference is in the shadow (his isn't
specified), the 8-neighbour repose, or how long he ran.

## Controls

Scenes 1–4: one wind, two winds, sandstone, plants. Drag on the desert to
pour sand, right-drag to dig. The cut follows the pointer. Space pauses, `r`
starts again, `f` is fast. One knob per scene:

- One wind: sand, 0.5–16 slabs a cell (restarts).
- Two winds: the angle between them, 0–180°, live, so the old dunes swing.
  Angles snap to integer hops of length about 6.5.
- Sandstone: how fast sand settles, 0–0.3 slabs a cell per unit, live.
- Plants: growth a season, 0–8%, live. Plants arrive at t = 150.

## How the code works

- `h` (Int32) is slabs per cell. `poll()` is one Werner poll; `advance(dt)`
  runs dt·N² polls, in steps of at most one time unit, switching winds,
  dropping falling sand, running a plant season and tracking dunes between
  steps. Time is Werner's: polls divided by cells.
- `inShadow(x, y)` walks upwind along the wind's unit vector, rounding to
  cells, until the 15° line from the global `hmax` can't reach. It is the
  cost centre, with the slides. Oblique winds round their hop to integers
  (`windNear`), so directions are quantised.
- `slideDown` (after a drop) and `slideIn` (after a pick-up) follow
  Werner: one slab at a time down or up the steepest step over 2 slabs,
  8 neighbours, diagonals weighted 1/√2.
- `layer` keeps a stamp per slab, `CAP` = 96 deep per cell. A slab is
  stamped when it comes to rest (drop or slide), so slides restamp too,
  which is right: that is when grain flow lays a lamina. Initial sand has
  `OLD`.
- Sandstone: when the lowest cell is above `SINK` + 4, every column drops
  `SINK` = 32 slabs off its bottom (`copyWithin`), so the record stays in
  the buffer and the panel.
- Dunes for the readout: 8-connected patches over 2 slabs deep and 50
  slabs big (`findDunes`), matched every 4 units to the patch that moved
  downwind and changed volume under 15% (`track`). Merged or split dunes
  start over.
- Drawing: heights smoothed 3×3, then lit by a low sun from the
  west-north-west, so slip faces fall into shade. Colour is relative to the
  mean height, so a rising floor doesn't wash out. The cut is a
  window on the pointer's row, scaled so a slab is a third of a
  cell (true scale); its window narrows from 160 to 80 cells as `hmax`
  grows.

## Speed

In Brave: about 120 time units a second at 200² and 1.5 slabs, 46 at 300².
The frame loop asks for 1 unit a frame (6 fast) within 14 ms, so the page
runs at roughly 30–40 units a second; barchans form in about five seconds.
A big pour is fine. Fifteen slabs a cell ran at about 10 units a second, one
more reason the star scene went.

## Testing

Everything is a page global. Set `isPaused = true`, then `advance(n)`,
`render()`, `updateReadout()`. Chunks of 150–250 units per
`javascript_tool` call stay under its timeout; 1200 in one call didn't.
`chooseScene(SCENES[k])`, `tracker.list`, `crestAngle(1, 0)`, `cutRow` and
`cutX` (set them to cut through a dune) are the useful handles. The Node
sweeps used a copy of the rule without the layer record. The page writes no
`localStorage` and makes no sound.

## Not done yet

- Star dunes (above).
- Sand rain only falls evenly. A sand source upwind (a beach, a dry river)
  with dunes marching away from it would make a dune field's age gradient.
- Barchan collisions only merge here. Real ones, and some models
  (Katsuki et al. 2005), can pass a small dune out the front.
- Wind ripples on the dunes: Werner's group did those too (Landry and
  Werner 1994).
- Sound: big dunes boom when their slip faces avalanche. The owner could
  hear that.
