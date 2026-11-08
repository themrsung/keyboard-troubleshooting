#!/bin/zsh
# trackball.sh: read and change the Nape Pro's trackball settings over USB, with the commands
# Keychron Launcher sends (a7 <cmd> ..., on the VIA interface). See README.md for the full table.
#
#   ./trackball.sh ./naperaw show                 # read-only: DPI, orientation, gestures, sleep, poll, battery
#   ./trackball.sh ./naperaw dpi 1                # switch to DPI step 1 (0-based)
#   ./trackball.sh ./naperaw dpi-value 1 1000     # set step 1 to 1000 DPI
#   ./trackball.sh ./naperaw angle 90             # ball orientation, in steps of 45°
#   ./trackball.sh ./naperaw layer-angle 1 90     # orientation used while layer 1 is active
#   ./trackball.sh ./naperaw gesture UP DOWN LEFT RIGHT   # 4 hex keycodes for the gesture layer (MO(9))
#   ./trackball.sh ./naperaw force GESTURE SCROLL         # 0/1 each; meaning not tested yet
#
# Every write is followed by the matching read, so the output shows what the device now holds.
naperaw=${1:?naperaw path}; shift
q() { $naperaw via a7 "$@" | sed -n 's/^via < //p'; }
b() { print -r -- ${${(z)1}[$2]}; }                        # byte N (1-based) of a reply
le() { local r=$1; print $(( 0x$(b "$r" $(( $2 + 1 )))$(b "$r" $2) )); }  # 16-bit little-endian at N

show() {
  local r=$(q 21); print "dpi step:        $(( 0x$(b "$r" 3) )) of $(( 0x$(b "$(q 3c)" 3) ))"
  local vals=(); for i in 0 1 2 3 4; do vals+=$(le "$(q 24 0$i)" 3); done
  print "dpi steps:       ${vals[*]}"
  print "custom dpi:      $(le "$(q 36)" 3)"
  print "orientation:     $(( 0x$(b "$(q 20)" 3) * 45 ))°"
  local la=(); for L in {0..8}; do la+=$(( 0x$(b "$(q 38 0$L)" 3) * 45 )); done
  print "layer angles:    ${la[*]}   (layers 0-8)"
  r=$(q 2a); print "gesture u/d/l/r: $(b "$r" 4)$(b "$r" 3) $(b "$r" 6)$(b "$r" 5) $(b "$r" 8)$(b "$r" 7) $(b "$r" 10)$(b "$r" 9)"
  r=$(q 33); print "force gest/scrl: $(( 0x$(b "$r" 3) )) / $(( 0x$(b "$r" 4) ))"
  r=$(q 0b); print "sleep (raw):     $(le "$r" 4) / $(le "$r" 6)   (Launcher: backlight / sleep)"
  print "poll (raw):      $(q 0d | cut -d' ' -f3-14)"
  r=$(q 31); print "battery:         $(( 0x$(b "$r" 3) ))% (byte 4: $(b "$r" 4))"
}
ok() { [[ $(b "$1" 3) == 00 ]] && print "ok" || print "reply: $1"; }

case $1 in
  show) show ;;
  dpi) ok "$(q 22 $(printf %02x $2))"; print "now: step $(( 0x$(b "$(q 21)" 3) ))" ;;
  dpi-value) ok "$(q 23 $(printf '%02x %02x %02x' $2 $(( $3 & 255 )) $(( $3 >> 8 ))))"
             print "now: step $2 = $(le "$(q 24 $(printf %02x $2))" 3)" ;;
  angle) ok "$(q 34 $(printf %02x $(( $2 / 45 ))))"; print "now: $(( 0x$(b "$(q 20)" 3) * 45 ))°" ;;
  layer-angle) ok "$(q 39 $(printf '%02x %02x' $2 $(( $3 / 45 ))))"
               print "now: layer $2 = $(( 0x$(b "$(q 38 $(printf %02x $2))" 3) * 45 ))°" ;;
  gesture) bytes=(); for k in $2 $3 $4 $5; do bytes+=(${k[3,4]} ${k[1,2]}); done
           ok "$(q 29 $bytes)"; show | grep gesture ;;
  force) ok "$(q 32 $(printf '%02x %02x' $2 $3))"; show | grep force ;;
  *) print "usage: trackball.sh NAPERAW show|dpi N|dpi-value N DPI|angle DEG|layer-angle L DEG|gesture U D L R|force G S"; exit 64 ;;
esac
