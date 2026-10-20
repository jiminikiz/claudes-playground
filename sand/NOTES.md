# Falling sand

A falling-sand toy in one HTML file, `sand.html`, with no dependencies. Built
2026-10-19 in the playground's first thread. The owner asked for some of the
reactions (glass, oil catching on lava) and left the rest to Claude.

## Materials

| Material | Paintable | Behaviour                                                                 |
| -------- | --------- | ------------------------------------------------------------------------- |
| sand     | 1         | Powder. Sinks slowly through liquids.                                     |
| water    | 2         | Liquid. Puts out fire (smoke), quenches lava to obsidian.                 |
| oil      | 3         | Liquid, floats on water. Burns slowly; burning oil stays put and flames.  |
| fire     | 4         | Stays on fuel and throws flames and embers; loose fire drifts up and dies. |
| plant    | 5         | Drinks touching water into more plant; spare water sprouts upward.        |
| stone    | 6         | Static.                                                                   |
| lava     | 7         | Viscous. Ignites fuel, melts sand to glass, crusts to stone doing it.     |
| steam    | 8         | Rises, condenses back to water (rain).                                    |
| ice      | 9         | Freezes water with a limited cold budget; melts near anything hot.        |
| glass    | no        | lava + sand                                                               |
| obsidian | no        | lava + water                                                              |
| ember    | no        | thrown by fire on fuel; arcs 30–60 cells and lights fuel it lands on      |
| snow     | no        | steam + ice. Falls, floats on water, melts near heat.                     |
| smoke    | no        | left by fire as it dies or meets water. The easy first discovery.         |

The five unpaintable ones are the "discoveries" line (`SECRETS`), saved per
browser in `localStorage` under `sand.found`.

## How the code works

- State is typed arrays over the grid: `type`, `life`, `col` (shade), `vel`
  (ember heading), `clock`. The grid's size is fixed at load (see below).
- `life` means something different per material: fire/smoke/steam lifetime,
  plant stored water, ice cold budget, ember flight time.
- `step()` scans bottom-up, alternating left/right each tick. `clock[i] ===
  tick` marks a cell already moved this tick, so nothing moves twice.
- `sinks(t, j)` is the one density rule: a mover displaces anything movable
  with lower `dens`.
- Fixed 60 Hz timestep; at most three steps per frame.

## Screens and touch

- The grid takes the shape of the stage it loads in: aspect clamped to
  0.45–3.2, and about one cell per 9 px² up to 54,000 cells (minimum 20,000).
  Measured sizes: phone 390×844 gives 122×182 at 3.0 px per cell, tablet
  820×1180 gives 213×254 at 3.7 px, a desktop 1874×1122 gives 259×208.
- The grid doesn't change after load; on rotate or resize, `fit()` rescales
  the canvas with square cells. Reload to get a grid shaped for the new
  orientation.
- The tool buttons are in the HTML, not built by the script. The stage is
  measured before the script runs, and an empty toolbar made the phone
  canvas 80 px too narrow.
- `scene()` is drawn on a 300×180 plan and stretched, with walls kept 3
  cells thick.
- `pointers` holds one stroke per finger, so several fingers pour at once.
  The starting brush is about 15 px across on screen, whatever the cell
  size.
- Touch screens (`hover: none` and `pointer: coarse`) get 40 px buttons, no
  key labels and their own hint line. Below 520 px tall the toolbar becomes
  one row you can swipe, and the hint and footer are hidden.
- Not yet tried on a real phone or tablet. It was tested in Brave iframes
  at four sizes, with synthetic two-finger touches.

## Tuning that mattered

- `burn[OIL]` was 0.5 at first and the whole oil layer went up in 1.5 s and
  floated away. At 0.06, with fuelled fire staying put, a burn front creeps
  across for about 5 s.
- `EMBER_RATE` 0.004 gave one or two embers in the air; 0.03 gives about 15 on
  a big fire.
- Painting happens in pointer events as well as the frame loop. Without that,
  a fast drag paints nothing.

## Not done yet

- Wind, or any field that pushes gases sideways.
- Seeds that fall like sand and grow into a plant only on sand next to water.
- Save and load a scene (the typed arrays serialise easily).
- Acid, which would need a rule for what it can't dissolve.
