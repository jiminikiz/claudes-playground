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
