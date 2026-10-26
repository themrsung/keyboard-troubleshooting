#!/usr/bin/env bash
# Split an HHKB Studio Keymap Tool "All Profiles" file (.hks) into one file per profile, or merge
# profiles back into one. Unfilled profiles get PFU's factory keymap for that slot.
# See README.md. Needs jq.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# An All Profiles export of a factory-reset HHKB Studio JIS.
factory="$here/defaults/factory.hks"

# The tool version these files were checked against (HHKB Studio Keymap Tool 1.1.2).
setting_version="1.1.0.0"
tool_version="1.1.2.0"
layers='["Normal","WithFn1","WithFn2","WithFn3"]'
tmp=""
trap '[[ -n $tmp ]] && rm -rf "$tmp"' EXIT

usage() {
  cat <<'EOF'
Usage:
  hhkb-studio-profiles.sh split [--single] IN.hks [OUTDIR]
      One file per profile of an All Profiles file, named IN-Profile1.hks … IN-Profile4.hks.
      Each is an All Profiles file with that profile in its slot and PFU's factory keymap in the
      other three. With --single, Current Profile files instead (one profile, no slot).

  hhkb-studio-profiles.sh merge OUT.hks [P1 [P2 [P3 [P4]]]]
      One All Profiles file from up to four sources, in slot order. Each source is:
        FILE        a Current Profile file
        FILE@N      profile N (1-4) of an All Profiles file
        -           PFU's factory keymap for that slot
      Slots left off the end are "-", so "merge OUT.hks" alone writes the factory keymaps.
      DIP switches, pointing-stick buttons and gesture pads come from the first source that
      isn't "-", or are the factory settings if there's none.

  hhkb-studio-profiles.sh check FILE...
      Print each file's type, model and profiles, and whether this script can read it.
EOF
}

die() { echo "hhkb-studio-profiles: $*" >&2; exit 1; }

command -v jq >/dev/null || die "jq is required (brew install jq)"

# Fail unless FILE is a Keymap Tool file this script understands.
check_file() {
  local f=$1
  [[ -f $f ]] || die "$f: no such file"
  jq -e --arg sv "$setting_version" --arg tv "$tool_version" --argjson layers "$layers" '
    (.SettingFileVersion == $sv) and (.ToolVersion == $tv)
    and (.SaveType == "All" or .SaveType == "Single")
    and ([.Keymap[] | (keys == ($layers | sort)) and all(.[]; length == 120)] | all)
  ' "$f" >/dev/null 2>&1 || die "$f: not an HHKB Studio Keymap Tool $tool_version file (setting file $setting_version) with 120-key layers"
}

# Print the profile (its four layers, as JSON) that SOURCE names, for slot SLOT.
profile_of() {
  local src=$1 slot=$2 file n
  if [[ $src == - ]]; then
    [[ -f $factory ]] || die "missing $factory: the factory keymaps"
    jq --arg p "Profile$slot" '.Keymap[$p]' "$factory"
    return
  fi
  if [[ $src == *@[1-4] ]]; then
    file=${src%@*} n=${src##*@}
    check_file "$file"
    jq -e --arg p "Profile$n" '.SaveType == "All" and (.Keymap | has($p))' "$file" >/dev/null ||
      die "$file: not an All Profiles file with Profile$n"
    jq --arg p "Profile$n" '.Keymap[$p]' "$file"
  else
    file=$src
    check_file "$file"
    jq -e '.SaveType == "Single"' "$file" >/dev/null ||
      die "$file: an All Profiles file; name the profile, e.g. $file@1"
    jq '.Keymap.Profile' "$file"
  fi
}

# Print the settings outside the keymap (DIP switches, pointing stick, gesture pads, model).
settings_of() {
  local file=${1%@*}
  jq 'del(.Keymap, .SaveType)' "$file"
}

# The model every factory keymap here was exported from.
factory_model() { jq -r '.TypeNumber' "$factory"; }

# Write an All Profiles file: SETTINGS (JSON) and four profiles (JSON files) to OUT.
write_all() {
  local out=$1 settings=$2; shift 2
  jq -n --argjson s "$settings" \
    --slurpfile p1 "$1" --slurpfile p2 "$2" --slurpfile p3 "$3" --slurpfile p4 "$4" '
    $s + {SaveType: "All",
          Keymap: {Profile1: $p1[0], Profile2: $p2[0], Profile3: $p3[0], Profile4: $p4[0]}}
  ' >"$out"
}

cmd_merge() {
  (($# >= 1 && $# <= 5)) || { usage >&2; exit 2; }
  local out=$1; shift
  while (($# < 4)); do set -- "$@" -; done
  local settings="" model i
  tmp=$(mktemp -d)
  for i in 1 2 3 4; do
    profile_of "${!i}" "$i" >"$tmp/p$i.json"
    if [[ -z $settings && ${!i} != - ]]; then settings=$(settings_of "${!i}"); fi
  done
  [[ -n $settings ]] || settings=$(settings_of "$factory" | jq '.DipSwitch |= map(false)')
  model=$(jq -r '.TypeNumber' <<<"$settings")
  for i in 1 2 3 4; do
    if [[ ${!i} != - ]]; then
      [[ $(jq -r '.TypeNumber' "${!i%@*}") == "$model" ]] || die "${!i}: a different model from $model"
    elif [[ $model != "$(factory_model)" ]]; then
      die "the factory keymaps here are for $(factory_model), not $model"
    fi
  done
  write_all "$out" "$settings" "$tmp/p1.json" "$tmp/p2.json" "$tmp/p3.json" "$tmp/p4.json"
  echo "$out"
}

cmd_split() {
  local single=false
  if [[ ${1:-} == --single ]]; then single=true; shift; fi
  (($# == 1 || $# == 2)) || { usage >&2; exit 2; }
  local in=$1 outdir=${2:-$(dirname "$1")} base n i out settings
  check_file "$in"
  jq -e '.SaveType == "All"' "$in" >/dev/null || die "$in: not an All Profiles file"
  base=$(basename "$in" .hks)
  mkdir -p "$outdir"
  settings=$(settings_of "$in")
  if ! $single && [[ $(jq -r '.TypeNumber' "$in") != "$(factory_model)" ]]; then
    die "the factory keymaps here are for $(factory_model), not $(jq -r '.TypeNumber' "$in"); use --single"
  fi
  tmp=$(mktemp -d)
  for n in 1 2 3 4; do
    out="$outdir/$base-Profile$n.hks"
    if $single; then
      jq --arg p "Profile$n" '.SaveType = "Single" | .Keymap = {Profile: .Keymap[$p]}' "$in" >"$out"
    else
      for i in 1 2 3 4; do
        if ((i == n)); then profile_of "$in@$n" "$i"; else profile_of - "$i"; fi >"$tmp/p$i.json"
      done
      write_all "$out" "$settings" "$tmp/p1.json" "$tmp/p2.json" "$tmp/p3.json" "$tmp/p4.json"
    fi
    echo "$out"
  done
}

cmd_check() {
  (($# >= 1)) || { usage >&2; exit 2; }
  local f
  for f in "$@"; do
    check_file "$f"
    jq -r --arg f "$f" '"\($f): \(.SaveType), \(.TypeNumber), tool \(.ToolVersion), profiles: \(.Keymap | keys | join(" "))"' "$f"
  done
}

case ${1:-} in
  split) shift; cmd_split "$@" ;;
  merge) shift; cmd_merge "$@" ;;
  check) shift; cmd_check "$@" ;;
  -h | --help | help) usage ;;
  *) usage >&2; exit 2 ;;
esac
