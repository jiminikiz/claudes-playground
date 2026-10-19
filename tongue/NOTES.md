# A tongue handed down

Iterated learning in one HTML file, `tongue.html`. A language for 27 pictures
(3 shapes × 3 colours × 3 motions, after Kirby, Cornish and Smith 2008) is
handed down a chain of learners. Each learner is a fresh small neural net. It
hears some of the previous generation's words, learns them, and names all 27.
Built 2026-10-19 in the playground's eighth thread. It is the first project
about culture: something no single member of the chain holds, shaped by being
passed on. The threads here are a chain like it, learning the folder from
notes.

What comes out of it (measured in Node over 6–8 seeds, 60 generations, then
seen again in the page):

- **No bottleneck, no grammar.** Hear all 27 and the random language is
  handed down whole: structure about 0.05, 27 words, no change.
- **Bottleneck alone collapses it.** Hear 14 with no wish to be understood
  (care 0) and within about 20 generations there are 1–3 words for everything.
  This is the first experiment of the 2008 paper.
- **Both make a grammar.** Hear 14 with care 8 and by generation 25–30 the
  language is compositional, keeps all 27 words, and stops changing: mean
  structure 0.86, 26.7 distinct words, 1% of syllables changing per
  generation. It has become a language that can be learnt from half of
  itself, so it passes through the bottleneck intact. This is Kirby, Tamariz,
  Cornish and Smith (2015): learning pulls towards simple, talking towards
  expressive, and you need both.
- **Grammar has room for variety.** Seen across runs, some while tuning: one syllable per attribute
  (`takuta takumo takune`), two-syllable affixes (`-lune` for circling), shape
  and colour fused into one part for some pairs, and a **zero morpheme**: one
  run gave circles no part at all, triangles `-ne` and squares `-neku`, the
  way English marks the plural and leaves the singular bare.
- **Too narrow a bottleneck never settles.** Hearing 8 of 27 leaves structure
  near 0.5 and 20% churn per generation. At 20 it still finds a grammar.
- Care 2 gives about 11 words and structure 0.5, between the regimes. Care
  above about 6 is reliably expressive. Up to 20 it changes little.

A perfectly compositional language with a zero morpheme scores only about
0.80 on the structure measure, because bare and suffixed words differ in
length. Read the glossary line, not just the number.

## Controls

Scenes 1–3: the chain (14 heard, care 8), no bottleneck (27), no listener
(care 0). Each starts a new random language and plays. Space plays or pauses,
`n` or → steps a generation, ← goes back, `f` fast, `r` new language, `y`
your turn. Sliders: words each learner hears (1–27), wants to be understood
(0–16). Drag along the chart to look back. Point at a picture for its history,
click to hear it.

**Your turn**: you hear what a learner would (study screen), then name all 27
in shuffled order. Words must be 1–4 of the 12 syllables. Your language
enters the chain as a white dot on the chart and the nets learn from you.

## How the code works

- Meaning `m` = shape·9 + colour·3 + motion. Input is three one-hots (9).
- A learner (`newNet`) is 9 → 64 tanh → 4 slots × 13 logits (12 syllables
  and a blank). `learn()` is cross-entropy with Adam (lr 0.02), run until
  every heard word comes back exactly, with at least 20 epochs and at most
  400. Stopping that early matters. 50 or 100 minimum epochs gave
  less structure (mean 0.71–0.72) because the net fits the heard words more
  arbitrarily.
- `speak(net, care)` scores all 22,620 possible words (1–4 syllables,
  blanks only at the end) for every meaning:
  log P(w|m) + care · log P(m|w), where P(m|w) is the net's own production
  probabilities inverted by Bayes over the 27 meanings. That is an obverter
  or RSA-style speaker: say what you learnt, unless you yourself would take
  it for something else. Care 0 is plain imitation (argmax per slot).
- Measures: `structure()` is topographic similarity, the Pearson r between
  meaning distance (attributes that differ) and normalised syllable edit
  distance over all 351 pairs. `change()` is mean normalised edit distance
  to the previous generation.
- `glossary()` reads a language like a linguist: for each attribute value, the
  run of 1–3 syllables (anywhere, or anchored to a slot 0–2 from the start or
  end) with the best F1 over the 27 words. It is kept at F1 ≥ 0.8, with ties
  going to the longer run, then the least anchored. A value whose siblings
  have runs, and whose own words carry none of them, gets ∅. `tints()`
  colours each syllable by the attribute it expresses.
- A generation takes about 14 ms in Brave. Play steps every 650 ms, fast
  every frame. History stops at 2000 generations.

## Testing

Everything is a page global. `nextGeneration()` adds one, `scene(k)`,
`freshLanguage()`, `record(lang, heard, who)` (inject a language, e.g. from
`'pikulu ...'.split(' ').map(parseWord)`), `updateReadout()`, `render()`.
Set `isPlaying = false` first so the frame loop doesn't add its own. The
sweeps were done in Node with the same model code. The page writes no
`localStorage`.

Speech uses `speechSynthesis` with an Italian or Spanish voice if there is
one, since those read CV syllables as written. **Nobody has heard it yet.**

## Not done yet

- On a phone the canvas text shrinks to about 7px. The lexicon could be an
  HTML grid instead.
- A population instead of a chain: several learners per generation, each
  hearing a mix of the elders.
- Holistic gen 0 is the only start. A start with a hand-made irregular
  language (like English's `went`) would show whether frequent irregulars
  survive, as they do in real languages, if heard words were sampled by
  frequency instead of uniformly.
- Bigger meaning spaces (4 attributes) to see whether word order emerges.
