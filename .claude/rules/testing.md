# Testing playground pages

- Serve the playground root in the background with
  `python3 -m http.server 8765 --bind 127.0.0.1`, open
  `http://127.0.0.1:8765/<project>/<file>.html` in Brave, and stop the server
  when done.
- Brave throttles `requestAnimationFrame` to about 2 fps when its window isn't
  focused. Judge motion by stepping the sim from `javascript_tool` (for sand:
  call `step()` n times, then `render()`) and screenshotting between batches.
- A synthetic drag ends before the next frame. Input handlers must act inside
  pointer events, not only in the frame loop.
- For a model with knobs to tune, sweep it in Node first and write a montage
  PNG (built-in `zlib`, no deps) to the scratchpad, then view it with Read.
  Much faster than tuning in the page.
- Remove any `localStorage` a test writes (sand: `sand.found`), so the owner's
  state stays theirs.
- Measure a threshold with runs held at fixed values, not a ramp. Near a
  tipping point a system takes ever longer to settle, so a sweep always
  finds it late (firefly: 1.2 Kc for a 1.03 Kc threshold).
- Stop the server with `kill` on its PID or by stopping the background task.
  `pkill -f "http.server 8765"` matches the shell running it and kills that
  too.
- A `javascript_tool` call that runs much past 20 s fails with an internal
  error (dune: 1200 time units at once). Step a slow sim in chunks, one call
  each.
- `resize_window` may not change Brave's viewport. To check phone width,
  load the page into a 390 px `iframe` from `javascript_tool` and compare the
  frame's `scrollWidth` with its `innerWidth` (tune: 371 against 386).
