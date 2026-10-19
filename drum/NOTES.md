# Hear the drum

Two drums side by side in one HTML file, `drum.html`. You draw a drum's shape,
strike it and hear it. Its spectrum is drawn as lines, and sand on the skin
settles into Chladni figures. Built 2026-10-19 in the playground's fourth
thread. It is the first project that makes sound, and the first that solves
for a shape's modes instead of stepping time forward.

Nothing below is scripted. Each one falls out of the modes:

- **Twins.** Gordon, Webb and Wolpert's pair (1992): two different shapes with
  the same spectrum, which answers Kac's "Can one hear the shape of a drum?"
  with no. The grid versions are exactly isospectral too: all 48 lines agree
  to 14 digits. Sand on the same mode makes different figures on each.
- **Faber–Krahn.** No drum of a given area sounds lower than the circle.
  Each drum's readout says how many cents it sits above a circle of the same
  area. The twins are 560¢ above, the square 59¢.
- **Area is pitch.** Half the skin sounds a tritone (√2) higher: 600¢ on the
  grid.
- **Where you strike.** Each mode starts in proportion to its shape at the
  strike point, so a hit on a nodal line silences that mode. The centre of a
  circle gives only the round modes.
- Symmetric shapes have paired modes at the same pitch (square, circle).

## Controls

Click a drum to strike it. Tools are strike (1), draw (2) and erase (3);
right-drag erases with any tool. `[` `]` set the brush. Click a spectrum line,
or press ← → over a drum, to play one mode as a pure tone and see its shape.
`s` scatters sand, `r` cycles scenes (twins, circle and square, half the skin,
blank), and `c` clears the drum under the cursor.

## How the code works

- Each drum is a 64×64 node mask. Skin nodes are unknowns; every other node
  is fixed at 0. The operator is -Δ (5-point, spacing 1), so the drum's area is
  its node count.
- `findModes(mask)`: nodes numbered row by row make -Δ banded, so `factor()`
  is a banded Cholesky (band = widest row, about 60). A block Krylov space of
  (-Δ)⁻¹, 140 vectors with block width 3, then Rayleigh–Ritz with `jacobi()`.
  The block width matters: a single start vector finds only one of a
  symmetric pair. 175 ms for a 1500-node drum, 370 ms at 2600. It runs on the
  main thread after a stroke ends.
- Residuals are about 1e-13 for the low modes and 1e-7 by mode 48. The square
  matches the exact discrete formula; the circle's ratios match the Bessel
  zeros to 3 digits.
- f = `HZ`·√λ. A full-width circle sits near G♯2.
- `circleLam(n)` is the Faber–Krahn bound. A grid disc's λ₁·n depends on its
  centre and radius by up to 3% at small n, so `DISC` holds the lower envelope
  over discs at four centres and radii 3 to 31 in quarter steps. Against the
  plain continuum formula, an octagon "beat the circle".
- The twins' vertices are COMSOL's (legs of 2), scaled ×10. λ₁·100 comes out
  2.5434 against Driscoll's 2.5379 for the true drums; it was 2.5450 at ×5, so
  the grid is converging on it.
- Sound: `playStrike` renders 3.5 s of damped sines with a rotating phasor,
  23 ms for 48 modes. Amplitude is φ_k(strike) × `rad`. `rad` is 0.15 plus
  |Σφ_k|/√n: modes whose halves cancel push little air. Decay is
  `ringTime(f)` = 1.4·√(100/f) s. Nothing here was tuned by ear, because no
  thread can hear. The envelope was checked as RMS by second: 0.125, 0.047,
  0.019, 0.007.
- The picture runs `SLOW` = 80 times slower than the sound and rings
  `SEEN_RING` times longer. `field()` fills `u` (height) and `env` (how hard
  each point shakes, from 0 to about 1).
- Sand: a grain hops up to `JUMP` cells where `env` exceeds `STICK` (gravity),
  and rejects a hop that would leave the skin. With JUMP 1.5, 66% of grains
  had settled on a mode after 10 s; at 2.5, 92%.

## How it sounds

No thread can hear, so the owner's ears are the only test. Their first
listen: hand pan, garbage can, long thin sheets of metal, gong, cymbal. So it
sounds like metal, not like a skin drum. It does follow the shape: smaller
drums are higher, bigger ones lower.

A guess, not yet tested: `ringTime` lets high modes ring nearly as long as low
ones (it scales as 1/√f). A real membrane loses its high modes fast to the air
it pushes, so a strike is mostly thump. A steeper fall-off, such as 1/f or
1/f², should sound more like a drum. To keep both sounds, make it a "skin or
metal" switch.

## Testing

`drums`, `scene(j)`, `strike(d, x, y)`, `select(d, k)`, `field(d, t)`,
`stepSand(d)`, `render()`, `drawSpectrum()`, `retune(d)` and `toggleSand()` are
page globals. x and y are cell coordinates within the drum. Retunes are
deferred by `setTimeout`, so wait about 1.5 s after `scene()`. For a Chladni
screenshot, call `select`, then run `field(d, i*0.016); stepSand(d)` 600
times, then `render()`. A strike's look depends on wall-clock time since
`hit.t0`, so set `t0` just before rendering. The page writes no
`localStorage`.

## Not done yet

- Plates. Real Chladni figures are on plates (∇⁴, free edges), not membranes.
  It needs a different operator, and free edges need their own stencil.
- Hearing the area: Weyl's law gives the area and perimeter from the
  eigenvalue count. 48 modes may be too few for the perimeter.
- More twins: Buser, Conway, Doyle and Semmler list 17 families; some aren't
  made of half-squares and won't sit on a grid.
- Moving the solve into a Worker, so large drums don't hitch the page.
