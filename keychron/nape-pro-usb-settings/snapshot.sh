#!/bin/zsh
# snapshot.sh: read-only dump of a Nape Pro's settings over USB, for backups and firmware diffs.
#   ./snapshot.sh ./naperaw > snapshot-$(date +%Y%m%d).txt
# Sends only VIA and Keychron "get" commands. Nothing is written to the device.
naperaw=${1:-./naperaw}
q() { $naperaw via "$@" | sed -n 's/^via < //p'; }

echo "# usb"
ioreg -r -c IOUSBHostDevice -n "${NAPE_USB_NAME:-Keychron Nape Pro}" -l -w0 |
  grep -E '^\s*\|?\s*"(idVendor|idProduct|bcdDevice)"' | sed 's/^[ |]*//' | sort -u

echo "# via: protocol 0x01, firmware value 0x02/04, layout options 0x02/03, layers 0x11, macros 0x0c, macro bytes 0x0d"
for c in "01" "02 04" "02 03" "11" "0c" "0d"; do echo "$c => $(q ${=c} | cut -d' ' -f1-8)"; done

echo "# keychron 0xa0..0xa3 (protocol, firmware string, features, default layer)"
for c in a0 a2 a3; do echo "$c => $(q $c | cut -d' ' -f1-8)"; done
echo "a1 => $(q a1 | cut -d' ' -f2- | xxd -r -p | tr -d '\0')"

echo "# keymap: 9 layers x 7 keycodes (DYNAMIC_KEYMAP_GET_BUFFER 0x12)"
bytes=()
for off in 0 28 56 84 112; do
  n=$(( off + 28 > 126 ? 126 - off : 28 ))
  bytes+=(${(z)$(q 12 00 $(printf %02x $off) $(printf %02x $n) | cut -d' ' -f5-$((4 + n)))})
done
for L in {0..8}; do
  line=""; for k in {0..6}; do i=$(( (L * 7 + k) * 2 + 1 )); line+="${bytes[i]}${bytes[i+1]} "; done
  echo "layer $L: $line"
done

echo "# encoder 0 (DYNAMIC_KEYMAP_GET_ENCODER 0x14): ccw cw"
for L in {0..8}; do
  ccw=$(q 14 0$L 00 00 | cut -d' ' -f5-6 | tr -d ' '); cw=$(q 14 0$L 00 01 | cut -d' ' -f5-6 | tr -d ' ')
  echo "layer $L: $ccw $cw"
done
