# Many-headed slime

A slime mould growing on a dish, in one HTML file, `slime.html`. You drop
flakes of oat and paint light; the slime spreads out as a sheet, then thins to
a network of tubes between the flakes. Built 2026-10-19 in the playground's
sixth thread. It is the first project about networks. _Physarum
polycephalum_ means "many-headed slime".

There is one rule: a tube that carries a lot of flow widens, and a tube that
carries little withers. Nothing searches for a route or measures a length.
Each of these comes out of that rule:

- **Steiner junctions.** Three towns get one junction in the middle with
  three tubes at 120°, not two roads between towns. The equilateral case
  settles at 1.01× the true shortest network and 0.87× the shortest
  town-to-town tree (the ideal is 0.866). Random triangles land within 1–2%
  of Steiner, including obtuse ones, where the right answer has no junction
  and the slime runs through the wide-angled town.
- **Mazes** (Nakagaki, Yamada and Tóth, 2000). Dead ends empty first, then
  the longer loops; the last tube lies on the shortest path (1.00× over three
  mazes tried). Paint light across it and it regrows and finds the next best.
- **Tokyo** (Tero et al., 2010). Thirty towns around the bay, grown out from
  Tokyo, with light for sea and mountains. It settles to loops round the bay
  with spurs to the outer towns: about 1.15× the shortest town-to-town tree,
  trips 1.4× the shortest way, and about half the tube on loops.
- **Cost against robustness.** The lean–spare slider trades length for loops.
  On Tokyo, γ 2.5 gives a bare tree (1.09×, detours 1.77×, 0% spare); γ 1.2
  gives 1.38×, detours 1.26×, 85% spare.

## Controls

Scenes 1–4: three towns, maze, Tokyo, empty dish. Pressing 1 or 2 again
gives a new triangle or maze. Click drops a flake, or takes one away. Drag
paints light, right-drag removes it. Point at a flake for its name (Tokyo).
Slider: lean to spare. `g` regrows over the whole dish, `f` fast, space
pauses.

## How the code works

- Tero, Kobayashi and Nakagaki, J. Theor. Biol. 244 (2007), with the sigmoid
  of Tero et al., Science 327 (2010). Each tube has conductivity `D`. Each
  step one flake at random pushes I0 = 1 in, and the other flakes joined to it
  draw it off in equal shares. Kirchhoff gives pressures, `Q = D/L·Δp`, then
  `D += dt·(f(|Q|) − D)` with `f = Q^γ/(1+Q^γ)`, dt 0.1. Tubes under 1e-6
  die.
- Dish: a jittered triangular lattice, 72×62 nodes 10 px apart, each linked to
  its 6 nearest and 6 next-nearest (27k edges). With 6 directions a tube at
  30° to the lattice is 15% too long, which ties the Steiner Y with the
  two-sided tree exactly: no junction can win.
- `flow()`: conjugate gradients with a Jacobi preconditioner on the source's
  component only, warm-started per source flake (`f.P`). Tolerance 1e-2 of
  I0 gives the same networks as 1e-6 in half the time. About 4.5 ms a step
  while the dish is a sheet, under 1 ms once it has thinned.
- **Young tubes explore.** A tube's γ rises from 1 to `gammaEnd` over
  `AGE` = 600 steps from its birth (`born[e]`). With γ fixed at 1.8 from the
  start, the first flake reached becomes a hub: three towns get two sides of
  the triangle, never the Y. With γ = 1 throughout it stays a blurry mesh.
- Growth: `grow()` covers nodes with fresh tubes (D0 0.2) and starts a front
  that advances one hop a step. `regrow(full)` starts a front from every
  living node; unless `full`, it stops once all flakes are joined and it has
  gone `MIN_HOPS` = 8. A new flake, a cut, or erased light triggers it.
- Light: a per-pixel `mask`. A node is lit by its pixel, an edge by its
  midpoint, so a thin stroke still cuts long edges. Flake nodes are never lit.
- Measures (`measure()`): tubes are living edges over 1% of the thickest.
  Length against the minimum spanning tree over shortest ways round the light
  (Dijkstra on the dark lattice), and against the exact three-point Steiner
  length when there are three flakes and no light. Detour: mean of tube path
  over shortest way, per pair. Spare: share of tube length not on a bridge
  (Tarjan) that separates flakes.
- Drawing: tube width goes as D^¼ (Poiseuille: conductance ∝ r⁴), in 14
  width buckets, each one `Path2D` stroked three times (shadow, body, shine).

## Tuning that mattered

- Feeding the foraging front as a sink (so a slow front stays alive) built
  spokes out of the first flake and lost the Steiner Y. A fast front (one
  hop a step) needs no feeding: the sheet outlives the crossing.
- `I0` barely changes the network here; the final γ is the knob that trades
  cost for loops, so the slider sets that.
- The square of four towns never finds its Steiner tree (two junctions,
  0.91× MST). It keeps all four sides as a loop, or three at high γ. The model
  isn't a pure length minimiser, so the square isn't a scene.
- The Tokyo towns are placed by hand from memory of a map, roughly, and are
  not Tero et al.'s 36. Don't compare it with real railway figures.

## Testing

`slime`, `foods`, `step()`, `render()`, `updateReadout()`, `measure()`,
`scene(k, again)`, `paint(x0, y0, x1, y1, on)`, `allJoined()`, `regrow()`,
`setPaused()` and `stage()` are page globals. Pause, step 1500 times, then
`render(); updateReadout()` and screenshot. After `paint()`, mimic pointerup:
`geoDirty = true; if (!allJoined()) regrow(false)`. Sweeps in Node used the
same model code with a PNG montage. The page writes no `localStorage`.

## Not done yet

- Shuttle streaming: real protoplasm flows back and forth every minute or so.
  The flow already flips as the source flake changes; the picture doesn't
  show it.
- Dim light that slows growth instead of blocking it, which is how Tero et
  al. drew mountains.
- Hunger: flakes that run out, so the network keeps rebuilding.
- Food of different sizes (a bigger flake pushes more), and seeing whether
  the network leans towards it.
- Moving the solve into a Worker.
