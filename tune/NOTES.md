# Tune

One HTML file, `tune.html`. Pick a tone or draw one, and the page works out
which intervals sound smooth in it, which makes that tone's scale. Built
2026-10-20 in the playground's eleventh thread. It is the first project about
music, and the first whose main claim no thread can check: whether something
sounds in tune.

The idea is William Sethares's (*Tuning, Timbre, Spectrum, Scale*, and his
1993 JASA paper): roughness between two notes comes from pairs of their
partials beating within a critical band (Plomp and Levelt, 1965). Add it up
over every pair and you get a curve with dips where partials line up. Those
dips depend on the tone, not on any numerology of ratios. Change the
overtones and the scale moves.

What comes out of it, measured in the page at C4:

- **A string gives Western intervals.** Harmonic partials put dips at 7:6,
  6:5, 5:4, 4:3, 7:5, 3:2, 8:5, 5:3, 7:4 and 2:1. 12-tone equal temperament
  sits near these and on none of them.
- **Stretch the tone, the octave stretches.** Partials at 2.1^log₂k put the
  deepest dip at 1284¢ (2.1:1, which is 1285¢) and the fifth at 751¢, where
  2.1^(7/12) is 750¢.
- **Any equal scale can be made smooth.** Snap harmonics to the nearest step
  of n per octave (Sethares's recipe) and the dips land exactly on the steps:
  checked for 5, 7, 10 and 12, nearly all of 19.
- **A clarinet has no octave.** Odd partials only: no dip at 2:1 (1222¢ is
  the nearest), the deepest at 3:1, and dips at 9:7, 7:5, 5:3, 9:5 and 7:3,
  which are notes of the Bohlen–Pierce scale (13 steps to 3:1).
- **A drumhead has no scale; the kettle gives it one.** An ideal membrane's
  Bessel-zero modes give a scatter of shallow dips and none at 2:1. With
  Rossing's (1992, *Physics Today*) measured timpani ratios, 1 : 1.5 : 1.98 :
  2.44 : 2.90, a clean fifth (702¢) and a near octave (1183¢) appear. Air
  loading did that, not the drummer.
- **Its own octave** is read off the curve: the first dip past 1000¢ within a
  quarter of the deepest one's depth (relative to the median). It is 1200¢ for
  the string, 1284¢ stretched, 1902¢ clarinet, 1544¢ timpani, 1689¢ skin,
  1166¢ bar. The triad map spans 0 to that.
- **Three-note chords** are a 2D map, a lattice of bright just-intonation
  lines. The smoothest chords for a string, ranked: 4:6:7, 9:12:16, 8:12:15,
  10:15:18, 3:4:5. Root-position major (4:5:6) and minor are local minima but
  not in the top eight; the model prefers wide spacings. That is the model's
  view, so the page shows it as is.
- **Low notes are rougher.** The same major triad scores 21.9 at C2 and 5.9
  at C4: the critical band is wider in cents down low, which is why close
  chords in the bass are muddy.
- **The bell's minor tierce doesn't make minor chords smoother.** Measured in
  all five registers, major beats minor by 1 to 3% for the bell, as it does
  for the string. Bell founders' "minor bell" lore isn't explained by
  roughness alone. The caption says so.

## Dream

`d` lets the overtones wander: each partial's log pitch is a damped spring
tied to its start and kicked by noise, so it drifts a few percent over tens
of seconds (sd about 0.03 in log pitch). The tone keeps playing a tune that
walks the dips of the scale it has at that moment, with a low chord from the
smoothest triad now and then.

The record strip under the curve is the picture of this. One row per change,
a dot at each dip, so a dream draws every scale note as a wandering thread.
Threads split and merge. Over three 60 s dreams of the string, each dip from
6:5 to 2:1 wandered with a standard deviation of 23 to 51¢; the octave was no
steadier than the rest (26 to 33¢), though one screenshot made it look so.

## How it sounds

No thread has heard it. Things to listen for, if the owner does:

- **Sethares's test** (the four buttons at the bottom): I–vi–IV–V–I, four
  voices, as a string in a 2:1 scale, stretched in a 2.1:1 scale, and both
  swapped. His prediction: ① and ② in tune, ③ and ④ sour. If ② sounds
  sour too, roughness isn't the whole story for the owner's ears.
- Whether the bell sounds sad.
- Whether the dream's tune sounds like music or like a random walk.

The synth is additive and plain: no vibrato, no noise, no body resonance.
"Held" tones have a 30 ms attack and 200 ms release; "struck" ones (skin,
timpani, bell, bar) a 3 ms attack and partials that decay with
τ = ring · √(f₁/f_k), so the high ones die first. Nothing was tuned by ear.
RMS by half-second, chord at C4: string 0.133 0.121 0.105; bell 0.155 down
to 0.020 over 6 s; skin 0.110 0.047 0.021.

## Controls

Tone buttons pick a preset; `n steps` with − + (or `-` `=`) is the equal-scale
spectrum. In the spectrum, drag a bar to move an overtone (across) or change
its loudness (up); double-click to add one or remove one. Click the curve to
hear that interval against the root (it snaps to a dip within 8 px). Keys
`1`–`0` then `q`–`o` play the dips in order. `space` plays the scale up to its
own octave, `p` plays the chord progression in the tone's own octave, `d`
dreams, `,` `.` change register (C2 to C6). Click the map to hear a chord; the
smoothest are ringed and listed on the right.

## How the code works

- `pl(lo, df)` is Sethares's `dissmeasure.m`: `5e^(-3.51 s) - 5e^(-5.75 s)`,
  `s = 0.24 df / (0.0207 lo + 18.96)`, weighted by min of the two amplitudes.
  `self(f)` sums it over a note's own partials, `cross(fa, fb)` between two
  notes. A dyad is `self(f) + self(g) + cross(f, g)`, as in his code.
- `computeCurve()` samples every cent from 0 to `CMAX` = 2000, about 5 ms for
  eight partials. `findValleys()` keeps local minima whose prominence is over
  2% of the curve's range. `findPeriod()` is the own-octave rule above.
- `computeMap(m)` fills an m×m grid over 0..period with `self` and
  `cross(root, ·)` cached per row, so each cell costs one `cross`. 150 cells
  a side normally, 60 while dragging and 80 while dreaming. The map is shaded
  by rank, not value, or the rough corner by the diagonal washes it out.
  Minima count only if among the smoothest fifth of chords and more than 50¢
  from a doubled note.
- `ratioLabel()` names a dip with the p:q of smallest p·q (at most 72) within
  7¢. `chordLabel()` finds k:a:b with k ≤ 12.
- Sound: `render()` adds rotating-phasor partials into one buffer per event
  and normalises it; everything goes through a compressor. `play()` takes a
  start time so the dream can schedule ahead.

## Testing

Everything is a page global. `setPreset(name)`, then read `curve`,
`valleys`, `period`, `mapMins`. To dream without the timer: `startDream();
clearInterval(dream.timer)`, then call `dreamTick()` n times (set `lastRow =
0` before `recordRow()` to force a row each tick). `render(tone, notes, sr)`
returns the samples, for RMS checks. The model was first checked in Node
against Sethares's published dip positions. The page writes no
`localStorage`.

## Not done yet

- Gamelan. Sethares matched measured saron and bonang spectra to slendro
  and pelog. It needs real measured partials, not ones from memory.
- The inverse problem done properly: given any scale, search for the
  spectrum that makes it smoothest, rather than snapping harmonics.
- Taking a spectrum from `drum/`: a drawn drum's 48 modes as a tone here,
  so a shape you drew gets its own scale.
- Harmonicity. Roughness doesn't know that 4:5:6 sounds like one note and
  wide spacings don't; adding a virtual-pitch term (Terhardt, Parncutt)
  might put the major triad back on top.
- Range past 2000¢, so the marimba's 4:1 shows as a dip, not just a calm.
