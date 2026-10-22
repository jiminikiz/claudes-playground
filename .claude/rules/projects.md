# Projects

> Subject to evolution.

If you choose to do a project, this is the current pattern.

- Read a project's `NOTES.md` before changing it
- Update a project's `NOTES.md` it in the same change.
- Notes describe the project as it is now, not the session that made it.
- A new project gets its own directory in the same shape

One directory per project: a single self-contained HTML file and a `NOTES.md`
written for the next thread. Add projects here when completed.

A project the owner has split out into its own repo is a git subtree here,
kept in step with `scripts/subtree.sh` (run it with no arguments for usage).
Its own repo is the main copy, so don't change it in the playground.

- `sand/`: falling-sand toy. Materials react, and eight can only be discovered.
  Its page is `index.html`, and it installs as an offline app.
  `sand/` is a git subtree of https://github.com/jiminikiz/sand, which is the
  main copy. Don't change `sand/` here: work on sand happens in that repo. To
  bring its latest in, run `scripts/subtree.sh pull sand`.
- `forth/`: a small Forth REPL with a 64×64 pixel screen.
- `terrarium/`: bugs with Forth brains in a soil-and-rain world. Brains mutate
  when bugs split, so species evolve.
- `ripple/`: a wave tank in red, green and blue. Interference, prisms, lenses,
  total internal reflection and Mach cones all come out of one wave equation.
- `drum/`: draw a drum, strike it and hear it. Its modes are solved exactly, so
  isospectral twins, Faber–Krahn and Chladni sand come out of the maths.
- `snow/`: two snow crystals grown side by side in a sky you steer. Arms,
  facets and plates come out of one lattice growth rule, and the ice keeps a
  record of the weather it froze in.
- `slime/`: a slime mould on a dish of oats and light. One rule (tubes that
  carry flow widen, idle ones wither) finds Steiner junctions, solves mazes
  and grows a rail network round Tokyo Bay.
- `memory/`: a Hopfield net holding one picture per project. It makes up a
  false memory, dreams it away (and everything else, if left too long), and
  hits the 0.138 N cliff. Its 2020 rule is softmax attention.
- `tongue/`: a language handed down a chain of neural nets through a
  bottleneck. Random words become a grammar, but only if learners hear part
  of it and want to be understood.
- `firefly/`: synchrony with no leader. Fireflies in a meadow, a crowd at
  Kuramoto's threshold, a chimera round a pond, and the Millennium Bridge
  wobbling at about 160 people.
- `dune/`: Werner's slab model of wind-blown sand. Barchans, ridges that
  flip at about 90° between two winds, parabolic dunes in scrub, and a cut
  that shows cross-bedding nobody drew.
- `tune/`: Sethares's roughness curves. A tone's overtones decide its scale:
  string, stretched, clarinet, drumhead, timpani, bell, bar, any n-step
  equal temperament, or one you draw. Its dream lets the overtones drift and
  plays a tune in whatever scale they make.
- `soup/`: Boerlijst and Hogeweg's hypercycle on a dish. Molecules that
  help each other copy form spirals, which shed parasites, die when stirred,
  and select against the molecules' own interest.
