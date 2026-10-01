#!/bin/sh
# Builds the submission archive for a playable-game platform: one self-contained
# index.html at the root of the zip, nothing else. Run it from anywhere.
#
#   tools/package.sh            -> dist/bad-driver-playable.zip
#
# The game has no build step and no dependencies, so "packaging" really is just
# zipping the one file. The checks below are the point: they fail loudly if the
# file ever grows a reference to something outside itself, which is the one
# thing that would get a submission rejected after it had already passed review.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out="$root/dist"
zipfile="$out/bad-driver-playable.zip"

cd "$root"

fail=0
note() { printf '%s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; fail=1; }

# Anything that would make the browser reach off-site at runtime.
for pat in 'src="http' 'src="//' 'href="http' 'href="//' '@import' 'fonts.googleapis' 'cdn\.' 'fetch(' 'XMLHttpRequest' 'importScripts'; do
  if grep -qF -- "$pat" index.html 2>/dev/null; then
    bad "index.html references '$pat' -- a submission must be self-contained"
  fi
done

# Size: platforms cap the archive (YouTube Playables at 30 MB). We are three
# orders of magnitude under it, so this only ever fires if something huge
# (a baked-in image, an audio file) gets inlined later.
bytes=$(wc -c < index.html | tr -d ' ')
if [ "$bytes" -gt 31457280 ]; then bad "index.html is ${bytes} bytes, over the 30 MB cap"; fi

[ "$fail" -eq 0 ] || { note ""; note "Not packaging while a check fails."; exit 1; }

mkdir -p "$out"
rm -f "$zipfile"
zip -q -X -9 "$zipfile" index.html
note "index.html   ${bytes} bytes"
note "archive      $(wc -c < "$zipfile" | tr -d ' ') bytes -> ${zipfile#"$root"/}"
note ""
note "Contents:"
unzip -l "$zipfile" | sed -n '4,$p' | sed '$d' | sed '$d'
