# Bad Driver

A single-file, mobile-first endless driving game with a neon-noir look. Weave
through night traffic, shave past cars to build a combo, sweep up coins, and see
how far the run goes before you wreck.

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

The workflow enables Pages itself on its first run. Where that is not
permitted — GitHub Pages only serves *private* repositories on a paid plan — it
skips the deploy and explains why in the run summary rather than failing, so a
red build never means "the game is broken". To enable Pages by hand, set
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

## Credits, goals and the garage

- **Credits** are laid down in trails along a lane, so collecting them is a
  line to drive rather than a dot to clip. A trail placed beside traffic is
  worth three times as much — that is the whole risk decision. Overdrive
  widens the pickup radius, so a hot streak sweeps the lane clean.
- **Goals** are ten one-off objectives (distance in a run, near-miss chains,
  overdrives, top speed, lifetime totals) that pay out in credits. They are
  checked live, so the payout lands in the moment you earn it, and the run's
  haul is summarised on the game-over card.
- **Cars** are bought with credits in the garage. They trade off against each
  other rather than being strictly better, so the choice is about how you want
  to drive:

  | Car | Trade-off |
  | --- | --- |
  | Nightshift | The stock cab — no strengths, no weaknesses |
  | Drifter | Whips between lanes, gives up top end |
  | Hauler | Wide, hard to thread, earns 70% more credits |
  | Bolt | Fastest on the road, steers like a brick |
  | Phantom | Slim hitbox, builds overdrive fast |
  | Sovereign | Everything tuned up, and priced accordingly |

  Every stat is a real multiplier on steering rate, steering response, top
  speed, hitbox width, overdrive fill, or credit value — and the car you drive
  is drawn at its actual width, so a wide car looks wide. The last two cars
  also need a specific goal completed, not just the credits.

- Progress is saved to `localStorage` under the `nightshift_v3` key (scores,
  credits, owned cars, completed goals, lifetime totals). A `nightshift_v2`
  score board from an earlier version is migrated across on first load rather
  than being discarded.

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
