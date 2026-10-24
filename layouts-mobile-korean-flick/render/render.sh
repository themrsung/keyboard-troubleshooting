#!/bin/sh
# Renders the golden layout and each candidates/<name>/layout.html to layout-light.png and
# layout-dark.png at 3x, with headless Google Chrome, and a layout's other layers to
# layout-<layer>-light.png and -dark.png.
# Run build.py first.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
width=500
for dir in "$here"/../*/ "$here"/../candidates/*/; do
  page="$dir/layout.html"
  [ -f "$page" ] || continue
  dom=$("$chrome" --headless --disable-gpu --window-size=$width,1200 --virtual-time-budget=5000 \
    --dump-dom "file://$page" 2>/dev/null)
  height=$(printf '%s' "$dom" | sed -n 's/.*data-height="\([0-9]*\)".*/\1/p' | head -1)
  # One pair of drawings per layer: layout-*.png for Korean, layout-<layer>-*.png for the others
  layers=$(printf '%s' "$dom" | sed -n 's/.*data-layers="\([^"]*\)".*/\1/p' | head -1)
  for layer in ${layers:-ko}; do
    suffix=""
    [ "$layer" = ko ] || suffix="-$layer"
    for theme in light dark; do
      sed "s/<html lang=\"en\">/<html lang=\"en\" data-theme=\"$theme\">/" "$page" >"$work/page.html"
      "$chrome" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=3 \
        --virtual-time-budget=5000 --window-size=$width,"$height" \
        --screenshot="$dir/layout$suffix-$theme.png" "file://$work/page.html?layer=$layer" >/dev/null 2>&1
    done
  done
  echo "$(basename "$dir"): ${width}x$height, layers: ${layers:-ko}"
done
