# Bad Driver

A single-file, mobile-first endless driving game with a neon-noir look. Weave
through night traffic, shave past cars to build a combo, sweep up the cash, and see
how far the run goes before you wreck.

## Play

Open `index.html` in any modern browser — no build step, no bundler, no
dependencies. The whole game (markup, styles, logic, and sound) lives in that
one file, and opening it on its own fetches nothing else. The only other files
in the repo are the home-screen icons and the manifest that names them, which a
browser fetches only when the page is the top-level document.

To serve it locally:

```sh
python3 -m http.server 8000
# then visit http://localhost:8000
```

## Hosting on GitHub Pages

`.github/workflows/pages.yml` publishes `index.html`, the manifest and the
icons to GitHub Pages on every
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

## Adding it to a phone home screen

Open the page in the phone's browser and use **Add to Home Screen** (iOS:
Share → Add to Home Screen; Android Chrome: ⋮ → Add to Home screen). It gets
the road-and-car icon rather than a screenshot of the page, and opens without
browser chrome.

The pieces that make that work:

| File | Who reads it |
| --- | --- |
| `manifest.webmanifest` | Android/Chrome — name, colours, `display: standalone`, and the icons |
| `icons/icon-192.png`, `icons/icon-512.png` | Chrome, for the shortcut and the splash; the 512 doubles as the maskable icon |
| `icons/icon-180.png` | iOS, via `<link rel="apple-touch-icon">` |
| `icons/icon-32.png` | the browser tab, for anything that wants a PNG |
| inline SVG `<link rel="icon">` | the tab, with no request at all |
| `/apple-touch-icon.png` at the site root | iOS again, when no link tag resolves — the Pages deploy puts a copy there |

`icons/icon.svg` is the source the PNGs are rendered from — by drawing it into
a canvas of the target size, not by screenshotting a page sized to match. The
screenshot route is viewport-dependent and got it wrong silently: the 180 and
192 shipped once with the artwork at a third scale in the top-left corner and
white around it, which is what iOS then put on the home screen. The QA suite now
decodes each shipped PNG and checks its size, that the corners are the night
background rather than white, that it is fully opaque, and that the car actually
drew. The artwork is the
game's own view — road running to a vanishing point, car on it — drawn with
nothing finer than a few pixels at 32px, and with everything that matters
inside the central circle Android crops a maskable icon to.

## Controls

| Input | Action |
| --- | --- |
| Drag anywhere in the lower part of the screen | Steer (the drag re-centres itself, so you can always steer back) |
| Release | The wheel springs back to centre |
| Left / right arrows, or A / D | Steer (desktop) |
| Tap (not drag) in the lower screen | Spend a charged Overdrive |
| Space or Enter | Start, restart, or spend Overdrive mid-run |
| ↑ or W | Spend Overdrive |
| M, or the ♪ button | Mute |

Tapping anywhere on the title or game-over screen also starts a run — restart
friction is what stops people playing "one more".

## How it plays

- **Near misses drive everything.** Squeezing past a car without hitting it
  scores a bonus and raises your combo. The multiplier climbs with the combo
  (up to ×8) and decays if you play it safe for too long.
- **Overdrive is banked, not automatic.** Near misses fill the meter under the
  HUD. A full meter *holds* — spending it is the decision: tap anywhere in the
  steering band (or space / ↑ / W) to burn it on a wall of traffic, or save it
  for the next surge. The engine opens up for five seconds: more speed, more
  score, a slimmer hitbox, a different-coloured car. Grazes during overdrive
  extend it a little, but they don't refill the meter — you have to come down
  and earn the next one. Until you have spent one by hand, a charge left
  sitting fires itself after eight seconds, so missing the prompt never costs
  you the mechanic.
- **Shoulders rumble, they don't kill.** Drifting off the tarmac scrubs speed
  and breaks your combo, but it won't end the run.
- **Traffic is guaranteed fair.** The spawner never leaves you with nowhere to
  go: it checks which lanes will be occupied *at the moment a wave reaches you*
  (traffic closes at different speeds, so spawn order isn't arrival order) and
  always leaves a reachable gap.
- Speed and traffic density ramp with time; two-car waves and lane-changing
  traffic are introduced as the run goes on.

## Credits, goals and the garage

- **Credits** are banknotes, laid down in trails along a lane, so collecting
  them is a line to drive rather than a dot to clip. A trail placed beside
  traffic is worth three times as much and arrives as a banded bundle rather
  than a single note — that is the whole risk decision. Overdrive widens the
  pickup radius, so a hot streak sweeps the lane clean.

  Money has its own colour throughout, kept clear of the other two the HUD
  uses: `--credit` (pale banknote green) for every amount, `--cash` for the
  note itself, against amber for score and mint for your best.
- **Goals** are nine tiered objectives (distance in a run, near-miss chains,
  overdrives, top speed, lifetime totals) that pay out in credits. They are
  checked live, so the payout lands in the moment you earn it, and the run's
  haul is summarised on the game-over card.
- **Cars** are bought with credits in the garage. They trade off against each
  other rather than being strictly better, so the choice is about how you want
  to drive:

  | Car | Trade-off |
  | --- | --- |
  | Beater | The stock cab — no strengths, no weaknesses |
  | Drifter | Whips between lanes, gives up top end |
  | Hauler | Wide, hard to thread, earns 70% more credits |
  | Bolt | Fastest on the road, steers like a brick |
  | Phantom | Slim hitbox, builds overdrive fast |
  | Sovereign | Everything tuned up, and priced accordingly |

  Every stat is a real multiplier on steering rate, steering response, top
  speed, hitbox width, overdrive fill, or credit value — and the car you drive
  is drawn at its actual width, so a wide car looks wide. The last two cars
  also need a specific goal completed, not just the credits.

- Progress is saved to `localStorage` under the `baddriver_v1` key (scores,
  credits, owned cars, completed goals, lifetime totals). Saves under the
  earlier `nightshift_v3` and `nightshift_v2` keys are migrated across on first
  load rather than being discarded.

## Embedding it in a platform

The game is a single self-contained file, which is what most playable-ad and
platform surfaces (YouTube Playables among them) require. Embedded in a frame
it is exactly one request: a manifest is only processed for a top-level
document, so the home-screen icons cost an embed nothing. What they also require is a lifecycle
conversation, and there is one place to wire that up.

**Where the SDK goes.** A platform SDK has to load before any game code so its
globals exist when the game boots. There is a marked slot for that script tag
immediately above the game's own `<script>` in `index.html`.

**What the game tells the host.** Four hooks, all no-ops by default:

| Hook | Fires |
| --- | --- |
| `firstFrameReady()` | Once, the frame after the first render is on screen |
| `gameReady()` | Once, immediately after it — the title screen is live |
| `runStarted()` | Every time a run begins |
| `runEnded(score, distance)` | Every time a run ends |

An adapter supplies them by declaring `window.BadDriverHost` **before** the
game script runs — anything it provides replaces the matching no-op:

```html
<script src="…platform-sdk.js"></script>
<script>
  window.BadDriverHost = {
    firstFrameReady: function () { PlatformSDK.firstFrameReady(); },
    gameReady:       function () { PlatformSDK.gameReady(); },
    runStarted:      function () { PlatformSDK.logEvent('run_start'); },
    runEnded:        function (score, distance) { PlatformSDK.submitScore(score); }
  };
</script>
<!-- the game's own script follows -->
```

Handlers can also be attached after boot with `BadDriver.on(name, fn)`.

**What the host can do to the game.** Published on `window.BadDriver` once boot
has finished, so nothing can be called before the machinery it touches exists:

| Call | Effect |
| --- | --- |
| `BadDriver.pause()` / `.resume()` | Pause and resume a run |
| `BadDriver.setMuted(bool)` | Mute or unmute all audio |
| `BadDriver.isPlaying()` | `true` only during an active, unpaused run |

The game already pauses itself on `visibilitychange` and on window blur, so a
host that hides the frame without telling us does not cost anyone a run.

These names are the game's side of the conversation, deliberately not a guess
at any particular SDK's API — an adapter maps them onto whatever the platform
actually calls.

For packaging and submission — building the archive, and what has and has not
been checked — see [PLAYABLES.md](PLAYABLES.md).

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
