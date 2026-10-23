#!/bin/sh
# Renders each layouts/<name>/layout.html to layout-light.png and layout-dark.png at 3x, with
# headless Google Chrome. Run build.py first.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
width=1240
for dir in "$here"/../*/; do
  page="$dir/layout.html"
  [ -f "$page" ] || continue
  [ "$(basename "$dir")" = render ] && continue
  height=$("$chrome" --headless --disable-gpu --window-size=$width,1200 --virtual-time-budget=5000 \
    --dump-dom "file://$page" 2>/dev/null | sed -n 's/.*data-height="\([0-9]*\)".*/\1/p' | head -1)
  for theme in light dark; do
    sed "s/<html lang=\"en\">/<html lang=\"en\" data-theme=\"$theme\">/" "$page" >"$work/page.html"
    "$chrome" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=3 \
      --virtual-time-budget=5000 --window-size=$width,"$height" \
      --screenshot="$dir/layout-$theme.png" "file://$work/page.html" >/dev/null 2>&1
  done
  echo "$(basename "$dir"): ${width}x$height"
done
