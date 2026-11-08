#!/bin/zsh
# apply.sh: write the keymap and dial from a snapshot file (snapshot.sh's format) to a Nape Pro.
#   ./apply.sh ./naperaw snapshot-v1.3.0.txt      # restore the keymap as shipped
#   ./apply.sh ./naperaw test-number-keys.txt     # 1–7 on the buttons, 8/9 on the dial
# Only the "layer N:" lines are used. Writes each key with DYNAMIC_KEYMAP_SET_KEYCODE (0x05, layer,
# row 0, col 0-6) and the dial with DYNAMIC_KEYMAP_SET_ENCODER (0x15), then reads everything back
# and compares. Take a snapshot first.
# Not DYNAMIC_KEYMAP_SET_BUFFER (0x13): on v1.3.0 it changes the stored keymap and reads back fine,
# but the buttons keep the old keys. 0x05 takes effect at once.
naperaw=${1:?naperaw path}; file=${2:?snapshot file}
q() { $naperaw via "$@" | sed -n 's/^via < //p'; }

# The first 9 "layer N:" lines are buttons (7 keycodes), the next 9 the dial (ccw cw).
keys=(); dial=()
while read -r line; do
  [[ $line == layer\ [0-8]:* ]] || continue
  codes=(${(z)${line#*:}})
  if (( ${#codes} == 7 )); then keys+=($codes); elif (( ${#codes} == 2 )); then dial+=($codes); fi
done < $file
(( ${#keys} == 63 && ${#dial} == 18 )) || { echo "expected 9 layers x 7 keys and 9 dial lines in $file"; exit 1; }

for L in {0..8}; do
  for c in {0..6}; do
    k=${keys[L * 7 + c + 1]}
    r=$(q 05 0$L 00 0$c ${k[1,2]} ${k[3,4]})
    [[ $r == "05 0$L 00 0$c ${k[1,2]} ${k[3,4]}"* ]] || { echo "key write layer $L col $c failed: $r"; exit 1; }
  done
done
for L in {0..8}; do
  for d in 0 1; do
    k=${dial[L * 2 + d + 1]}
    r=$(q 15 0$L 00 0$d ${k[1,2]} ${k[3,4]})
    [[ $r == 15* ]] || { echo "dial write layer $L failed: $r"; exit 1; }
  done
done

# Read back.
here=${0:A:h}
diff <(grep '^layer' $file) <($here/snapshot.sh $naperaw | grep '^layer') && echo "written and read back: matches $file"
