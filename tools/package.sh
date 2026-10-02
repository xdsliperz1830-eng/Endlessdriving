#!/bin/sh
# Builds the submission archive for a playable-game platform: index.html, the
# web-app manifest, and the home-screen icons it names. Run it from anywhere.
#
#   tools/package.sh            -> dist/bad-driver-playable.zip
#
# The game has no build step, so "packaging" is zipping a handful of static
# files. The checks below are the point: they fail loudly if the page ever grows
# a reference to something outside the archive, which is the one thing that
# would get a submission rejected after it had already passed review.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
out="$root/dist"
zipfile="$out/bad-driver-playable.zip"
files="index.html manifest.webmanifest icons/icon-32.png icons/icon-180.png icons/icon-192.png icons/icon-512.png"

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

# Every local file the page or the manifest points at has to be in the archive.
# A 404 on an icon is silent in the browser: the shortcut just gets a generic
# glyph and nobody finds out until it is on someone's home screen.
#
# Read one reference per line rather than splitting on whitespace -- the inline
# SVG favicon is a data: URI full of spaces, and splitting it turned every path
# command in it into a "missing file". Scan markup tags only, or the same
# happens to every JavaScript string containing src=".
reflist=$(mktemp)
{ grep -E '^[[:space:]]*<(link|script|img)[[:space:]]' index.html \
    | sed -n 's/.*\(href\|src\)="\([^"]*\)".*/\2/p'
  sed -n 's/.*"src"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' manifest.webmanifest
} > "$reflist"

while IFS= read -r r; do
  case "$r" in ''|'./'|data:*) continue ;; esac
  if [ ! -f "$r" ]; then bad "referenced file is missing: $r"; continue; fi
  case " $files " in *" $r "*) ;; *) bad "referenced file is not in the archive: $r" ;; esac
done < "$reflist"
rm -f "$reflist"

for f in $files; do
  [ -f "$f" ] || bad "missing: $f"
done

# Size: platforms cap the archive (YouTube Playables at 30 MB). We are three
# orders of magnitude under it, so this only fires if something huge gets added.
bytes=$(cat $files | wc -c | tr -d ' ')
if [ "$bytes" -gt 31457280 ]; then bad "the payload is ${bytes} bytes, over the 30 MB cap"; fi

[ "$fail" -eq 0 ] || { note ""; note "Not packaging while a check fails."; exit 1; }

mkdir -p "$out"
rm -f "$zipfile"
zip -q -X -9 "$zipfile" $files
note "payload      ${bytes} bytes across $(echo $files | wc -w | tr -d ' ') files"
note "archive      $(wc -c < "$zipfile" | tr -d ' ') bytes -> ${zipfile#"$root"/}"
note ""
note "Contents:"
unzip -l "$zipfile" | sed -n '4,$p' | sed '$d' | sed '$d'
