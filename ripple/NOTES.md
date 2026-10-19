# Ripple tank

A wave tank in one HTML file, `ripple.html`. You place sources, wave bars,
walls, shallows and sponge, and watch the waves. Built 2026-10-19 in the
playground's third thread. The first two projects are grids of discrete
cells; this one is a continuous field, so it is the playground's first
physics that isn't a cellular automaton.

Waves come in three colours, and white is all three. Colour is wavelength:
red is long, blue is short, and the shallows slow blue more than red, as
glass does.

Every effect comes from one rule, the 2D wave equation, solved per cell.
Nothing below is coded as a feature. Each one turns up by itself:

- interference between two sources, and the double-slit fringes; in white
  light the centre fringe is white and the outer ones split into colours
- refraction through a prism, which spreads a white beam into a spectrum
- a lens focusing, with each colour at a slightly different distance
  (chromatic aberration); a parabolic wall focuses all colours at one point
- total internal reflection guiding waves round a curved strip (the fiber)
- the Doppler effect when a source is dragged, and a Mach cone once it moves
  faster than its waves (the page shows "Mach 1.4")
- standing waves and reverberation in a closed tank
- different colours passing through each other without making fringes

## Tools

| Tool     | Key | What it does                                                   |
| -------- | --- | -------------------------------------------------------------- |
| pebble   | 1   | Click drops a white ring. Dragging pushes a wake in proportion to speed. |
| source   | 2   | Click places an oscillator and keeps hold of it, so you can drag. |
| wave bar | 3   | Drag draws a line of sources in phase, which makes plane waves. |
| wall     | 4   | Paints a hard reflector (`u = 0`).                             |
| shallows | 5   | Paints water where waves slow down: red 0.69×, green 0.63×, blue 0.56×. |
| sponge   | 6   | Paints an absorber.                                            |

`l` cycles the light (white, red, green, blue) for new sources and bars, and
recolours the one you are holding. Any tool drags an existing source or bar.
Right-click removes one, or erases material back to open water. `v` switches
between waves and energy (the running average of u², on a log scale). `e`
toggles open and closed edges. `r` cycles the scenes: two sources, two slits,
prism, lens, dish, fiber.

## How the code works

- Grid is 416×296: the visible 360×240 tank plus a 28-cell margin `P`. With
  open edges the margin damps quadratically towards the rim, so outgoing waves
  are soaked up instead of echoing. Closed edges make the margin solid.
- Each colour is its own field: `U[c]`, `PREV[c]`, `ENERGY[c]` for c in
  red, green, blue. The equation is linear, so separate fields added together
  are exact, and two colours never interfere. A source's `mask` says which
  fields it drives (white is 7).
- Wavelengths keep light's ratios (650 : 530 : 450 nm); the slider sets
  green's. Shallow indices are 1.45 / 1.6 / 1.8, about 15× the spread of real
  glass, so a prism visibly separates them. At 1.8, blue goes totally
  internally reflected at 34°, so the prism scene's beam angle was chosen to
  let all three out.
- `stepChannel(c)` is leapfrog: `next = (2-d)·u - (1-d)·prev + k2·lap(u)`.
  `k2` is `(c·dt/dx)²` by kind and channel (`K2`), 0.25 in open water
  (c = 0.5 cells a step; the scheme is stable below 1/√2). `d` is per-cell
  damping. Walls are `solid` and pinned to 0.
- `awake[c]` counts down steps since anything drove channel c. At zero the
  channel is cleared and skipped, so a red-only tank costs a third.
- `settle(i)` derives `solid` and `damp` from `kind` and the edge mode. Call
  it after changing `kind`; `settleAll()` after a bulk change.
- Sources add `sin(phase) - sin(phase - ω)` each step, not `sin(phase)`.
  Adding sin is a velocity kick with a non-zero running sum, and it raises the
  whole tank.
- Bars fade in over 14 cells at each end. Hard ends spray fans of light.
- Sources are bilinearly splatted at a position interpolated through the
  frame (`step(f)`), so a dragged source moves smoothly between steps.
  `s.px, s.py` is where it was at the end of the last frame. Mach is the
  smoothed speed over `C`.
- Pebbles add a Gaussian to all three fields' `u` and `prev`: a displacement
  with no velocity.
- `render()` adds the colours: in the waves view crests glow in their colour
  and troughs darken the water; in the energy view each colour's log energy
  adds. Exposure follows the tank. `x / (1 + |x|)` stands in for `tanh`,
  which cost 4 ms a frame.
- With all three colours on: about 1.85 ms a step, 6 steps a frame, plus
  about 3 ms to render.

## Tuning that mattered

- Energy on a linear scale showed the standing wave in front of the slits and
  nothing behind them. Log scale over 2.5 decades fixed it; exposure at
  1/(15·mean) keeps white beams from washing out.
- The fiber's source and the prism's bar sit in the margin, where their
  backward spray is absorbed and only the useful part enters the tank.
- A closed tank with no loss rings up slowly without limit near a resonance
  (peak 0.56 to 0.80 over 30,000 steps). `CLOSED_LOSS` 0.001 holds it at
  about 0.2.

## Testing

`step()`, `render()`, `drawOverlay()`, `scene(j)`, `setPaused()`,
`setClosed()`, `toggleView()`, `sources`, `bars`, `U`, `ENERGY` and `awake`
are page globals. Pause, step a few thousand times from `javascript_tool`,
then call `render()` about 40 times so the exposure settles before a
screenshot. To see a Mach cone without dragging, push a source by 0.8 cells
(Mach 1.6) each step and set `px = x` after each. The page writes no
`localStorage`.

## Not done yet

- Per-source pitch within one colour, so two greens could beat.
- More than three colours. Each one is another field and another 0.6 ms a
  step.
- A probe that plays the wave at one point as sound.
- Real deep-water waves (speed growing with wavelength) would turn the
  pebble-drag Mach cone into a Kelvin wake with its fixed 19.5° angle.
