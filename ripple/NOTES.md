# Ripple tank

A wave tank in one HTML file, `ripple.html`. You place sources, wave bars,
walls, shallows and sponge, and watch the waves. Built 2026-10-19 in the
playground's third thread. The first two projects are grids of discrete
cells; this one is a continuous field, so it is the playground's first
physics that isn't a cellular automaton.

Every effect comes from one rule, the 2D wave equation, solved per cell.
Nothing below is coded as a feature. Each one turns up by itself:

- interference between two sources, and the double-slit fringes
- refraction and focusing through a lens of shallows
- a parabolic wall focusing a plane wave to a point
- total internal reflection guiding waves round a curved strip (the fiber)
- the Doppler effect when a source is dragged, and a Mach cone once it moves
  faster than its waves (the page shows "Mach 1.4")
- standing waves and reverberation in a closed tank

## Tools

| Tool     | Key | What it does                                                   |
| -------- | --- | -------------------------------------------------------------- |
| pebble   | 1   | Click drops a ring. Dragging pushes a wake in proportion to speed. |
| source   | 2   | Click places an oscillator and keeps hold of it, so you can drag. |
| wave bar | 3   | Drag draws a line of sources in phase, which makes plane waves. |
| wall     | 4   | Paints a hard reflector (`u = 0`).                             |
| shallows | 5   | Paints water where waves move at 1/1.6 speed (index 1.6).      |
| sponge   | 6   | Paints an absorber.                                            |

Any tool drags an existing source or bar. Right-click removes one, or erases
material back to open water. `v` switches between waves and energy (the
running average of u², on a log scale). `e` toggles open and closed edges.
`r` cycles the scenes: two sources, two slits, lens, dish, fiber.

## How the code works

- Grid is 416×296: the visible 360×240 tank plus a 28-cell margin `P`. With
  open edges the margin damps quadratically towards the rim, so outgoing waves
  are soaked up instead of echoing. Closed edges make the margin solid.
- `step()` is leapfrog over two `Float32Array`s, `u` and `prev`:
  `next = (2-d)·u - (1-d)·prev + k2·lap(u)`. `k2` is `(c·dt/dx)²`, 0.25 in
  open water (c = 0.5 cells a step; the scheme is stable below 1/√2). `d` is
  per-cell damping. Walls are `solid` and pinned to 0.
- `settle(i)` derives `solid`, `k2` and `damp` from `kind` and the edge mode.
  Call it after changing `kind`; `settleAll()` after a bulk change.
- Sources add `sin(phase) - sin(phase - ω)` each step, not `sin(phase)`.
  Adding sin is a velocity kick with a non-zero running sum, and it raises the
  whole tank. All sources share one global phase and wavelength, so they are
  always coherent.
- Sources are bilinearly splatted at a position interpolated through the
  frame (`step(f)`), so a dragged source moves smoothly between steps.
  `s.px, s.py` is where it was at the end of the last frame. Mach is the
  smoothed speed over `C`.
- Pebbles add a Gaussian to both `u` and `prev`: a displacement with no
  velocity.
- Display exposure follows the tank (RMS for waves, mean for energy), so one
  pebble and a full scene both read. The energy view spans 2.5 decades,
  because a slit passes about a hundredth of what hits it.
- 6 steps a frame at about 0.55 ms a step.

## Tuning that mattered

- Energy on a linear scale showed the standing wave in front of the slits and
  nothing behind them. Log scale fixed it.
- The fiber's source at first sat inside the strip in open water. Its direct
  spray drowned the guided part. It now sits in the margin, where the spray
  is absorbed and only what the fiber carries enters the tank.
- A closed tank with no loss rings up slowly without limit near a resonance
  (peak 0.56 to 0.80 over 30,000 steps). `CLOSED_LOSS` 0.001 holds it at
  about 0.2.

## Testing

`step()`, `render()`, `drawOverlay()`, `scene(j)`, `setPaused()`,
`setClosed()`, `toggleView()`, `sources`, `bars`, `u` and `energy` are page
globals. Pause, step a few thousand times from `javascript_tool`, then call
`render()` about 40 times so the exposure settles before a screenshot. To see
a Mach cone without dragging, push a source by 0.8 cells (Mach 1.6) each step
and set `px = x` after each. The page writes no `localStorage`.

## Not done yet

- Per-source frequency. Two slightly different pitches would beat.
- Dispersion: speed that depends on wavelength, so a prism would split a
  mixed wave. The plain wave equation has none, apart from grid error.
- A probe that plays the wave at one point as sound.
- Real deep-water waves (speed growing with wavelength) would turn the
  pebble-drag Mach cone into a Kelvin wake with its fixed 19.5° angle.
