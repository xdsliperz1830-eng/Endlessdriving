# Submitting as a playable

Everything in this file is about shipping the game to a platform that hosts
playable games (YouTube Playables is the one it was prepared for). For what the
game offers a host at runtime, see **Embedding it in a platform** in
[README.md](README.md) — this is the packaging and submission side.

## Build the archive

```sh
tools/package.sh      # -> dist/bad-driver-playable.zip
```

There is no build step: the archive is `index.html` at the root of a zip and
nothing else, ~45 KB. The script's real job is the checks it runs first. It
refuses to package if `index.html` has grown a reference to anything off-site
(`src="http`, `@import`, a CDN, `fetch`, `XMLHttpRequest`) or if the file has
somehow grown past the 30 MB cap. Those are the two ways a submission that
passed review once can quietly start failing later.

`dist/` is not committed.

## Verified here

Driven by automated passes against the real game in headless Chromium, touch
events only — no keyboard anywhere in the mobile suite:

- **Self-contained.** Loading the game makes exactly one network request (the
  document). Zero off-site requests, with `data:` URIs — the garage car
  thumbnails — correctly excluded from that count, since they are inline.
- **Touch-only play.** Title, garage (buying and selecting a car), goals,
  starting, steering, pause/resume, music and mute toggles, the end card,
  CONTINUE, share, and DRIVE AGAIN are all reachable and operable by tap and
  drag alone.
- **Small screens and every aspect ratio.** 320×568, 360×640 and landscape
  844×390, plus eight further viewports: no clipped controls, nothing
  off-screen, no horizontal overflow, no exceptions. The end card is the
  tightest fit — worst case it needs 17 px of scroll, and every button on it is
  still reachable and tappable.
- **Cold start.** A player with no save: no stored state is required for the
  title screen, the garage, or a first run.
- **Audio policy.** No `AudioContext` exists before the player's first gesture;
  the tap on START creates one already in `running` state, which is what
  autoplay-restricted embeds require. Backgrounding and returning does not
  leave it suspended.
- **No leaks over a long session.** Ten simulated minutes: obstacles, pickups,
  particles, popups, streaks, banners, audio slots, end-card rows and garage
  thumbnails all stay bounded.
- **Pausing.** The game pauses itself on `visibilitychange` and on window blur,
  so a host that hides the frame without telling us costs nobody a run.
- **SHARE degrades inside a frame.** A cross-origin frame that was not given
  `allow="web-share"` still exposes `navigator.share`, and every call rejects.
  The button falls through to the clipboard, and says `COPY FAILED` if that is
  blocked too, rather than going silent. Dismissing the share sheet copies
  nothing.
- **No hint names a key that is not there.** The three "press SPACE" hints
  switch to tap wording on a coarse, hoverless pointer, and keep the key on a
  machine that has one.
- **Gameplay fairness.** Across ten scripted player profiles — including ones
  that hug a wall, never steer, or graze every car — no wave ever spawns with
  all lanes blocked.

## Still to do, and why not here

- **Wire the SDK.** The script tag slot and the four lifecycle hooks are in
  place and tested against a stub host, but the adapter is written against the
  platform's actual API, and this environment cannot reach
  `developers.google.com` to confirm the current call signatures. Read the
  platform's own reference and fill in the adapter shown in the README; do not
  trust a signature written from memory.
- **Partner access.** YouTube Playables is invitation-only. Submission needs an
  onboarded partner account, which is an account action, not a code change.
- **Store assets and metadata.** Title, description, age rating and icon are a
  submission form, not part of the build. Screenshots are in `press/`, captured
  from the running game at a real phone viewport (390x844 CSS px at
  device-pixel-ratio 3, so 1170x2532) and in landscape: the title screen, the
  garage, a run in traffic, the end card, and landscape play. The two action
  shots are the last frame before a genuine crash, which is why the road is
  full in them; nothing is composited or retouched.
- **Real-device fill rate.** Frame cost was measured in headless Chromium,
  which software-rasterises the canvas and so says nothing useful about GPU
  fill rate. The game is cheap in JS (sub-millisecond per frame with the canvas
  isolated), but confirming it holds 60 fps on a low-end phone needs that
  phone.
