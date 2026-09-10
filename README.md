# Nightshift — Endless Drive

A single-file, mobile-first endless driving game. Steer a car through night
traffic with a draggable steering wheel and see how far you can get before you
wreck.

## Play

Open `index.html` in any modern browser — there is no build step, no bundler,
and no dependencies. The whole game (markup, styles, and logic) lives in that
one file.

To serve it locally:

```sh
python3 -m http.server 8000
# then visit http://localhost:8000
```

It can also be published straight to GitHub Pages from the repository root.

## Controls

| Input | Action |
| --- | --- |
| Drag anywhere in the lower band of the screen | Turn the steering wheel to steer |
| Release the drag | Wheel springs back to center |
| Left / right arrow keys | Steer (desktop fallback) |
| Spacebar | Start or restart a run |

## How it plays

- Three lanes of traffic scroll toward you; obstacles spawn at random lanes.
- Speed and spawn rate ramp up the longer you survive.
- Distance is your score, and your best run is saved to `localStorage`
  under the `nightshift_best` key.

## Tech

Plain HTML, CSS, and JavaScript rendering to a single `<canvas>` element, with
a `devicePixelRatio`-aware backing store so it stays sharp on high-density
displays. The HUD, steering wheel, and overlays are DOM elements layered above
the canvas.
