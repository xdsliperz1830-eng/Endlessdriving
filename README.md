# Nightshift — Endless Drive

A single-file, mobile-first endless driving game. Weave through night traffic,
shave past cars to build a combo, and see how far the run goes before you wreck.

## Play

Open `index.html` in any modern browser — no build step, no bundler, no
dependencies, no assets. The whole game (markup, styles, logic, and sound)
lives in that one file, and loading it makes exactly one network request.

To serve it locally:

```sh
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Hosting on GitHub Pages

`.github/workflows/pages.yml` publishes `index.html` to GitHub Pages on every
push to the default branch, and can be run by hand from the Actions tab. Once
it succeeds the game is live at:

```
https://xdsliperz1830-eng.github.io/Endlessdriving/
```

**This repository is currently private.** GitHub Pages only serves private
repositories on a paid plan (Pro, Team, or Enterprise). On a free account the
deploy will fail until the repository is made public under
*Settings → General → Danger Zone → Change visibility*.

The workflow enables Pages itself on its first successful run, so there is
normally nothing to configure by hand. If that step is blocked, set
*Settings → Pages → Source* to **GitHub Actions** and re-run the workflow.

There is no build step, so *Settings → Pages → Source → Deploy from a branch*
(branch: the default branch, folder: `/ (root)`) also works and needs no
Actions run at all. A `.nojekyll` file is committed so Pages serves the files
as-is rather than running them through Jekyll.

The page is entirely self-contained, so it works correctly from the
`/Endlessdriving/` sub-path Pages serves it from — there are no absolute paths
or external resources to break.

## Controls

| Input | Action |
| --- | --- |
| Drag anywhere in the lower part of the screen | Steer (the drag re-centres itself, so you can always steer back) |
| Release | The wheel springs back to centre |
| Left / right arrows, or A / D | Steer (desktop) |
| Space or Enter | Start, or restart after a wreck |
| M, or the ♪ button | Mute |

Tapping anywhere on the title or game-over screen also starts a run — restart
friction is what stops people playing "one more".

## How it plays

- **Near misses drive everything.** Squeezing past a car without hitting it
  scores a bonus and raises your combo. The multiplier climbs with the combo
  (up to ×8) and decays if you play it safe for too long.
- **Overdrive.** Near misses fill the meter under the HUD. Fill it and the
  engine opens up: more speed, more score, a different-coloured car. Grazes
  during overdrive extend it a little, but they don't refill the meter — you
  have to come down and earn the next one.
- **Shoulders rumble, they don't kill.** Drifting off the tarmac scrubs speed
  and breaks your combo, but it won't end the run.
- **Traffic is guaranteed fair.** The spawner never leaves you with nowhere to
  go: it checks which lanes will be occupied *at the moment a wave reaches you*
  (traffic closes at different speeds, so spawn order isn't arrival order) and
  always leaves a reachable gap.
- Speed and traffic density ramp with time; two-car waves and lane-changing
  traffic are introduced as the run goes on.
- Score, best score, and best distance are saved to `localStorage` under the
  `nightshift_v2` key.

## Tech

Plain HTML, CSS, and JavaScript rendering to one `<canvas>`, with a
`devicePixelRatio`-aware backing store so it stays sharp on high-density
displays. The HUD, steering wheel, and overlays are DOM layered above it.

The road is drawn in one-point perspective: depth runs `0` (horizon) to `1`
(the camera plane), and both the screen Y and the road's half-width are driven
by the same easing curve — which is what keeps the road edges straight in
screen space. Gameplay positions are kept in road-space units (`-1` to `1`
across the tarmac) rather than pixels, so collision behaves identically at
every screen size. Collisions are tested on the frame a car *crosses* the
player's plane rather than against a depth band, so nothing can tunnel through
at high speed.

All audio is synthesised with the Web Audio API — an engine drone whose pitch
and filter track your speed, plus whooshes, combo blips, and crash noise. No
audio files, and nothing starts until you press play.
