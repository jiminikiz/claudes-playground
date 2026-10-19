# Letters from the sky

Two snow crystals growing side by side in one HTML file, `snow.html`. You
steer the weather while they grow, and each crystal keeps a record of the sky
it fell through. Built 2026-10-19 in the playground's fifth thread. It is the
first project about growth: a shape that builds itself from a field (vapour)
and keeps its own history.

The title is Nakaya's: he called snow crystals letters sent from the sky,
because you can read the weather back off one.

Nothing below is coded as a shape. Each one comes out of the growth rule:

- **Arms and branches.** A tip reaches more vapour than the ice behind it, so
  it outgrows its neighbours (the Mullins–Sekerka instability). With easy
  attachment you get ferns.
- **Facets.** When new ice struggles to take hold on an edge (high β), hollows
  fill first and faces stay flat: plates, then sectored plates and broad arms.
- **The Berg effect.** A hexagonal plate sits in round vapour contours, so its
  corners see more vapour than the middles of its faces. Arms start at the
  corners. The vapour view shows it.
- **History in the ice.** A change of weather mid-fall leaves a mark: plate
  centres with fern arms, fern arms that end in plates, banded rings. These
  match real crystal types (stellar dendrite with a plate centre, stellar
  plate, and so on).
- **Twins.** The two crystals share every bit of weather and differ only in
  the jitter in the air. They come out alike but not the same, as in
  Libbrecht's lab-grown "identical twin" snowflakes. The faster they grow, the
  less they agree: a fern amplifies noise, a plate damps it.

## Controls

Skies 1–6 restart the pair with a preset weather path. Dragging the dot on the
pad takes over (your own sky), and works while they grow; on a finished pair
it starts a new one. Pointing at ice dims everything that froze later, marks
the growing edge at that moment in gold, and shows the weather then on the
pad. Pointing at the pad's path does the reverse. `v` vapour view, space
pauses, `n` regrows with new noise.

## How the code works

- Gravner and Griffeath, "Modeling snow crystal growth II: A mesoscopic
  lattice map with plausible dynamics", Physica D 237 (2008). Each site has
  vapour `d`, boundary layer `b`, ice mass `c`, and an attached flag `a`. A
  step: diffusion (mean of self and six neighbours; ice reflects), freezing
  at the boundary (`b += (1-κ)d`, `c += κd`), attachment (1–2 ice neighbours
  need `b ≥ β`; 3 need `b ≥ 1`, or `b ≥ α` with neighbourhood vapour `< θ`;
  4+ always), melting (`μ` of `b`, `γ` of `c` back to vapour), then noise
  `d ×= 1 ± σ`. The noise is folded into the diffusion pass.
- Axial hex lattice in an `N×N` array, neighbours `±1, ±N, ±(N-1)`. The air
  is a disc of radius `R` = 140 sites. `N` is `2.32·R`, not `2R`: the disc
  reaches further than `R` along the slanted axis. With `2R`, reads ran off
  the array and vapour went NaN.
- Outside the disc the far air is held at the sky's vapour `ρ`. A change of
  `ρ` rescales all free air at once (`setRho`): the crystal falls into the new
  layer whole. Waiting for it to diffuse in from the rim would take tens of
  thousands of steps.
- Only boundary sites are visited after diffusion (`edge` list, `onB` flags,
  `nA` ice-neighbour counts updated on attach). `born[i]` is the step a site
  froze, which is all the rewind needs.
- The pad's two knobs are `β` (facets, 1.2–3.0) and `ρ` (vapour, 0.4–0.8).
  `α` 0.2, `θ` 0.025, `κ` 0.005, `μ` 0.03, `γ` 0.0001, `σ` 0.003 are fixed.
  The pad's region names come from a 4×5 sweep of those two at R = 60.
  "Temperature" isn't modelled. In real ice it sets attachment, which `β`
  stands in for.
- Preset skies are functions of crystal A's radius, not of time, so a stage
  ends at the same size whatever the growth rate.
- Drawing: a lookup from panel pixel to site (cube rounding, the lattice's q
  axis pointing up), then LUTs: ice by `c` (ridges are thick ice), air by
  `d/ρ`. 3.3 ms a frame for both panels.
- Speed: 1.4–1.6 ms a step for both crystals. The frame loop grows for 11 ms,
  about 480 steps a second. The presets finish in 1k (fern) to 9k (rings)
  steps, 2–20 s.

## Tuning that mattered

- A plain plate (β 2.7, ρ 0.75) took over 20k steps, more than a minute, and
  looked like a hexagon. The third preset is broad arms instead (β 2.2,
  ρ 0.75, 8.5k steps).
- The plate stages of the two-stage skies were at ρ 0.5 and took 18k steps.
  At ρ 0.7–0.75 they look the same and take 6–9k.
- The vapour view was first a linear fill, which is a flat bright disc,
  because the starved layer is only about 5 sites thick at a tip (15 in the
  hollows). Three contours over a dark fill show it.

## Testing

`flakes`, `step()`, `render()`, `drawPad()`, `newPair(SKIES[k])`, `SKIES`,
`setPaused()`, `toggleVapour()`, `isGrowing`, `trail`, `hoverT` and `T` are
page globals. Pause, then `while (flakes.some(isGrowing)) step()` and
`render(); drawPad()` before a screenshot. Set `hoverT` to a step to see the
rewind. The page writes no `localStorage`.

## Not done yet

- Thickness. The model is 2D, so there are no columns, capped columns or
  needles: half of Nakaya's diagram. Gravner and Griffeath also have a 3D
  version.
- A real temperature axis: the Nakaya diagram's plate–column–plate–column
  swaps between −2, −5, −15 and −25 °C.
- Steering by drawing a whole sky path first, then growing a crystal down it.
- Moving the growth into a Worker. The main thread holds it to about 480
  steps a second.
