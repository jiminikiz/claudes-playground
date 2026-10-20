# Fireflies in step

Synchrony in one HTML file, `firefly.html`: four crowds of clocks, each a
little fast or a little slow, nudged by what they see of the others. Built
2026-10-19 in the playground's ninth thread. It is the first project about
time, and about agreement with no leader: nobody keeps the beat and nobody
counts in.

What comes out of it (measured in Node and then in the page):

- **The meadow finds one tempo.** 500 pulse-coupled fireflies, natural
  periods 1 s ± 3%, each seeing those within 80 px. At start the best 3%
  window of periods holds about 40% of them. By 5 s there are three rival
  tempos, by 15 s two, by 30 s one (96–99%). Each reacts 3 frames late, so
  agreement travels as waves from a few origins (seen in a Node montage).
  Below about 50 px of sight it never finds one tempo.
- **A fast lantern conducts the fireflies that can see it.** A lantern at
  0.85 s takes 37% of the meadow, every one flashing at exactly 0.85 s, and
  the rest keep 1.01 s. A lantern doesn't take over the whole meadow. A
  **slow** lantern (1.2 s) can't slow anyone down. The fireflies near it
  flash *faster* (0.8–0.88 s) and ragged. Why isn't worked out: a flash
  that lands late in a cycle fires it early, which may be the whole story.
- **The crowd tips over at Kuramoto's Kc.** 1000 all-to-all fireflies with
  Gaussian rates (σ = 0.5 rad/s, so Kc = σ√(8/π) = 0.80). Held at K = 1.2 Kc
  it settles at r = 0.661 against the theory's 0.663. Measured r matched the
  self-consistency curve to within 0.02 at every K tested from 1.1 to 3 Kc.
  Below Kc, r sits at the 1/√N noise (0.03).
- **A sweep always arrives late.** Ramping K at 0.01 Kc/s, r passes 0.3 at
  1.15–1.25 Kc; theory says 1.03. Near Kc the crowd takes longer and longer
  to make up its mind (critical slowing down). At 0.02 Kc/s it was 1.24–1.37.
- **The pond splits: a chimera.** Abrams and Strogatz's ring, 128 identical
  oscillators with cosine-weighted nonlocal coupling. About 30% of them (the
  far bank) lock at one rate. The rest drift faster, with the classic arched
  rate profile. Nothing in the rule tells them apart.
- **Small rings can't hold a chimera.** Median lifetime in model time units
  over 8 seeds: 195 at N = 16, 175 at 24, 470 at 32, 1145 at 40. At 48 most
  were still split at 20,000. Roughly exponential in N, as Wolfrum and
  Omel'chenko (2011) showed. The page runs 4 units per second, so 32 lasts
  about 2 minutes.
- **The bridge wobbles at about 160 people.** Strogatz et al.'s Millennium
  Bridge model with the parameters from their supplement (M = 1.13e5 kg,
  B = 1.10e4 kg/s, K = 4.73e6 kg/s², G = 30 N, C = 16 m⁻¹s⁻¹, α = π/2,
  walker rates N(Ω₀, 0.63 rad/s)). Held 400 s: 0.5 cm at 150, 2.7 cm at 170,
  6.6 cm at 200, 9.5 cm at 250. The test walk (100, then +10 every 90 s)
  passes 1 cm at 170 in all three runs. Arup's real test found about 160.
  With dampers (B × 20) 250 people make 0.04 cm.

The threshold printed on the bridge, Nc = 2 B Ω₀ / (π G C P(Ω₀)) = 149, is
derived on this page, not copied. The locked walkers' work against the
bridge's velocity must beat damping. The supplement gives a closed form too,
but its PDF text came out garbled, so it wasn't checked against this one.
The simulation agrees with 149 to within its noise.

## Controls

Scenes 1–4: meadow, crowd, pond, bridge. Space pauses, `r` starts again,
`f` is fast (8 frames per frame, 30 on the bridge). One knob per scene:

- Meadow: how far they see (20–160 px). Click to hang a fast lantern
  (0.85 s), right-click a slow one (1.2 s), click a lantern to remove it.
- Crowd: K from 0 to 3 Kc. `s` sweeps it from 0 to 2.5 Kc at 0.01 Kc/s and
  reports where r passed 0.3.
- Pond: fireflies round the bank (16–256). Click the bank to stir the
  phases there the way the paper started its runs.
- Bridge: people on it (0–300). `t` is the test walk, `d` the dampers.

## How the code works

- Each scene is an object with `init`, `step` (one 60 fps frame), `render`,
  `readout`, an optional `click`, and a `knob` description. `scene(n)` swaps
  them; the frame loop calls `current.step()` 1 or `FAST` times a frame.
- Meadow: phase θ ∈ [0, 1) runs at the firefly's own rate and it flashes at
  1. A seen flash arrives LAT = 3 frames later and shifts θ by
  EPS · prc(θ) / k̄, with prc(θ) = −sin(2πθ)/2π (advance in the second half,
  delay in the first) and 0 for θ < 0.15. k̄ is the mean neighbour count, so
  EPS is the pull of a whole neighbourhood. EPS = 2 locked everything in 5 s,
  too fast to watch, so it is 1. A lantern is seen from 2.5 R and counts as
  2 k̄ fireflies. In Node at latency 4 a lantern was ignored; at 1 it took
  the whole meadow; at 3 it takes what it can see.
- "Tempos" (`tempos()`): each firefly's recent period (EMA over flashes),
  then the densest 3% window, removed, repeated while a window holds 10%.
  Grouping by chaining neighbours within 2% merged everything into one
  tempo, because the spread is continuous; don't go back to it.
  "In step with neighbours" is the mean local order parameter; chance is
  about 0.2 at 23 neighbours.
- Crowd: Euler at 1/120 s, two substeps a frame, rates from Gaussian
  quantiles (`erfinv`, Giles 2010) so there's no sampling luck.
  `theory(K)` bisects r = K r ∫cos²φ g(K r sin φ) dφ.
- Pond: RK4 at h = 0.05 model units. The kernel 1 + A cos(x − x′) has only
  Fourier modes 0 and ±1, so the coupling sum is O(N) through three complex
  sums. Rates are an EMA over 60 units; "locked" is the largest set within
  0.01 of each other. The split ends when global r > 0.99.
- Bridge: semi-implicit Euler at 0.01 s. Walker k's rate is the Gaussian
  quantile of the van der Corput number vdc(k), so any crowd size is an even
  spread of rates and the threshold doesn't depend on who turned up. The
  deck is drawn as a half-sine mode, 400× exaggerated. "Walking in time" is
  the share with |Ωᵢ − Ω₀| ≤ C·A, the locking condition.
- `drawTrace` is the flash (or footfall) count per frame for the last 6 s:
  noise when out of step, spikes when in. It is the quickest way to see it.

## Testing

Every scene object is a page global (`meadow`, `crowd`, `pond`, `bridge`),
as are `scene(n)`, `render()`, `updateReadout()` and `isPaused`. Set
`isPaused = true`, then e.g. `while (meadow.t < 60) meadow.step()`. The crowd
sweep: `crowd.init(); crowd.startSweep(); while (crowd.k < 2.5) crowd.step()`
(about a second). The bridge test: `bridge.startTest(); while (bridge.test)
bridge.step()`, then read `bridge.points`. The sweeps behind the meadow and
lantern numbers were done in Node with the same model. The page writes no
`localStorage` and makes no sound.

## Not done yet

- Sound. Snowy tree crickets chirp in step, and an audience's applause
  falls into rhythm by halving its clapping rate, then loses it when it
  speeds up to be louder (Néda et al. 2000). That would be a fifth scene the
  owner could hear.
- Pteroptyx malaccae learns a lantern's tempo and keeps it after the lantern
  goes (Ermentrout 1991). A first try at frequency adaptation here made the
  swarm drift slower overall, which wasn't understood, so it was left out.
- Fireflies that move, so neighbourhoods change. The meadow's neighbour
  lists are fixed.
- On a phone the canvas text shrinks to about 6 px.
