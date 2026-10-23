# An ANSI board started working as JIS after VIA's legend language changed

**Status:** observed once; cause unconfirmed.

A MONGDOL 87 BT-1 (an ANSI tenkeyless board, USB 0x36B0:0x3004 over Bluetooth) was remapped in VIA
with JIS's extra keys: `KC_KANA` (カタカナ) bottom-left, and ¥ (`KC_JYEN`) and ろ (`KC_RO`) on the Fn
layer ([us-ansi-87-key-to-jis](../../layouts/us-ansi-87-key-to-jis/README.md)).

1. With macOS storing the board as ANSI (40), カタカナ acted as かな (it went to Japanese) unless
   Karabiner-Elements was modifying the board.
2. Stored as JIS (42) by hand (`defaults write`) and the input method restarted: the input method's
   hardware listener saw ¥, ろ and 英数 from the board, but not カタカナ, and macOS typed nothing for
   ¥ and ろ, although Karabiner-EventViewer showed the board sending the right usages (0x88, 0x89,
   0x87). Karabiner's device settings were changed during this test, which may have played a part.
3. Then, in VIA (usevia.app), the **keycap legend language** was set to **Japanese**: the language
   of the legends VIA draws on the keys, not VIA's interface language. After that, macOS's Japanese
   Kana input typed ー め ろ from the Fn layer, and カタカナ worked, without Karabiner.

The legend language should only change what VIA draws, so the change may be coincidence: a
reconnect or restart around the same time could explain it as well. The way to store a remapped
board as JIS is Keyboard Setup Assistant: Z for the key right of the left Shift, then Fn + the ろ
key for the key left of the right Shift (see the background in the [README](../../README.md)).

If you can reproduce or rule out the legend language's effect, please add it here.
