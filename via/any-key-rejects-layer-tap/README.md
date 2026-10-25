# VIA's Any key wouldn't take LT(x,y)

**Status:** worked around; cause not investigated.

With a Hansung TFG Magnetox XF loaded in [usevia.app](https://usevia.app) through a draft
definition ([via-definition-magnetox-xf](../../hansung/via-definition-magnetox-xf/README.md)),
VIA's **Any** key didn't accept a layer-tap keycode such as `LT(1,KC_KANA)` (tap カタカナ, hold
layer 1; `HoldTap(KeyMomentaryLayerOne, KeyJISKLangKorean)`). The keyboard reports VIA protocol 12.

The keyboard itself takes the keycode: writing `0x4188` (`LT(1,KC_KANA)`) with
[viahid](../raw-hid-keymap-editing/README.md) stored it, VIA's keymap read it back, and the key
works as tap カタカナ (`KeyJISKLangKorean`) / hold layer 1 (`KeyMomentaryLayerOne`).

```sh
./viahid --vid 0x0416 --pid 0x8144 set 0 5 0 4188
```

Not checked: whether VIA rejects the expression's syntax (spaces, `KC_` names, layer numbers above
what the definition declares) or keycodes outside its basic picker for draft definitions. If you
know, a note here would help.
