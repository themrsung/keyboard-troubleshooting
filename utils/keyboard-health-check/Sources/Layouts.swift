// The three full-size boards drawn on screen: US ANSI (104 + 4 = 108), ISO (105 + 4 = 109) and JIS
// (109 + 4 = 113). The 4 extras sit above the numpad: Mute, Vol−, Vol+, Calc. Positions are in key
// units (1u = one letter key). Each key carries its HID usage, which is what lights it, and its
// canonical name from conventions/keynames/REV1-20261025/KEYNAMES.md.

struct Usage: Hashable {
    let page: UInt32
    let id: UInt32
    static func key(_ id: UInt32) -> Usage { Usage(page: 0x07, id: id) }
    static func consumer(_ id: UInt32) -> Usage { Usage(page: 0x0C, id: id) }
    var hex: String { String(format: "0x%02X:0x%02X", page, id) }
}

struct Key {
    let legend: String
    let name: String       // canonical key name
    let usage: Usage
    let x: Double, y: Double, w: Double, h: Double
    var isoEnter = false   // drawn as the ISO/JIS L-shaped Enter (x, y is the top part)
}

struct Board {
    let title: String
    let keys: [Key]
    static let width = 22.5, height = 6.5
}

private struct Spec {
    let legend: String, name: String, usage: Usage, w: Double, h: Double, gapBefore: Double
}

/// One key: legend, canonical name, keyboard-page usage, width. `gap` leaves space before it.
private func k(_ legend: String, _ name: String, _ usage: UInt32, _ w: Double = 1, h: Double = 1, gap: Double = 0) -> Spec {
    Spec(legend: legend, name: name, usage: .key(usage), w: w, h: h, gapBefore: gap)
}
private func c(_ legend: String, _ name: String, _ usage: UInt32, gap: Double = 0) -> Spec {
    Spec(legend: legend, name: name, usage: .consumer(usage), w: 1, h: 1, gapBefore: gap)
}
private func row(_ y: Double, _ specs: [Spec], from x0: Double = 0) -> [Key] {
    var x = x0
    return specs.map { s in
        x += s.gapBefore
        defer { x += s.w }
        return Key(legend: s.legend, name: s.name, usage: s.usage, x: x, y: y, w: s.w, h: s.h)
    }
}

// Rows 0 and the navigation / numpad blocks are the same on all three boards.
private let functionRow = row(0, [
    k("Esc", "KeyEscape", 0x29),
    k("F1", "KeyFunctionOne", 0x3A, gap: 1), k("F2", "KeyFunctionTwo", 0x3B), k("F3", "KeyFunctionThree", 0x3C), k("F4", "KeyFunctionFour", 0x3D),
    k("F5", "KeyFunctionFive", 0x3E, gap: 0.5), k("F6", "KeyFunctionSix", 0x3F), k("F7", "KeyFunctionSeven", 0x40), k("F8", "KeyFunctionEight", 0x41),
    k("F9", "KeyFunctionNine", 0x42, gap: 0.5), k("F10", "KeyFunctionTen", 0x43), k("F11", "KeyFunctionEleven", 0x44), k("F12", "KeyFunctionTwelve", 0x45),
    k("PrtSc", "KeyPrintScreen", 0x46, gap: 0.25), k("ScrLk", "KeyScrollLock", 0x47), k("Pause", "KeyPause", 0x48),
    c("Mute", "KeyMute", 0xE2, gap: 0.25), c("Vol−", "KeyVolumeDown", 0xEA), c("Vol+", "KeyVolumeUp", 0xE9), c("Calc", "KeyCalculator", 0x192),
])

private let navigation =
    row(1.5, [k("Ins", "KeyInsert", 0x49), k("Home", "KeyHome", 0x4A), k("PgUp", "KeyPageUp", 0x4B)], from: 15.25)
    + row(2.5, [k("Del", "KeyDeleteRight", 0x4C), k("End", "KeyEnd", 0x4D), k("PgDn", "KeyPageDown", 0x4E)], from: 15.25)
    + row(4.5, [k("↑", "KeyUpArrow", 0x52)], from: 16.25)
    + row(5.5, [k("←", "KeyLeftArrow", 0x50), k("↓", "KeyDownArrow", 0x51), k("→", "KeyRightArrow", 0x4F)], from: 15.25)

private let numpad =
    row(1.5, [k("Num", "KeyWINNumlock", 0x53), k("/", "KeyNumpadDivide", 0x54), k("*", "KeyNumpadMultiply", 0x55), k("-", "KeyNumpadMinus", 0x56)], from: 18.5)
    + row(2.5, [k("7", "KeyNumpadSeven", 0x5F), k("8", "KeyNumpadEight", 0x60), k("9", "KeyNumpadNine", 0x61), k("+", "KeyNumpadPlus", 0x57, h: 2)], from: 18.5)
    + row(3.5, [k("4", "KeyNumpadFour", 0x5C), k("5", "KeyNumpadFive", 0x5D), k("6", "KeyNumpadSix", 0x5E)], from: 18.5)
    + row(4.5, [k("1", "KeyNumpadOne", 0x59), k("2", "KeyNumpadTwo", 0x5A), k("3", "KeyNumpadThree", 0x5B), k("Ent", "KeyNumpadEnter", 0x58, h: 2)], from: 18.5)
    + row(5.5, [k("0", "KeyNumpadZero", 0x62, 2), k(".", "KeyNumpadDecimal", 0x63)], from: 18.5)

private let digits = row(1.5, [
    k("1", "KeyOne", 0x1E), k("2", "KeyTwo", 0x1F), k("3", "KeyThree", 0x20), k("4", "KeyFour", 0x21), k("5", "KeyFive", 0x22),
    k("6", "KeySix", 0x23), k("7", "KeySeven", 0x24), k("8", "KeyEight", 0x25), k("9", "KeyNine", 0x26), k("0", "KeyZero", 0x27),
], from: 1)
private let qRow = row(2.5, [
    k("Q", "KeyQ", 0x14), k("W", "KeyW", 0x1A), k("E", "KeyE", 0x08), k("R", "KeyR", 0x15), k("T", "KeyT", 0x17),
    k("Y", "KeyY", 0x1C), k("U", "KeyU", 0x18), k("I", "KeyI", 0x0C), k("O", "KeyO", 0x12), k("P", "KeyP", 0x13),
], from: 1.5)
private let aRow = row(3.5, [
    k("A", "KeyA", 0x04), k("S", "KeyS", 0x16), k("D", "KeyD", 0x07), k("F", "KeyF", 0x09), k("G", "KeyG", 0x0A),
    k("H", "KeyH", 0x0B), k("J", "KeyJ", 0x0D), k("K", "KeyK", 0x0E), k("L", "KeyL", 0x0F),
], from: 1.75)
private let zLetters: [Spec] = [
    k("Z", "KeyZ", 0x1D), k("X", "KeyX", 0x1B), k("C", "KeyC", 0x06), k("V", "KeyV", 0x19), k("B", "KeyB", 0x05),
    k("N", "KeyN", 0x11), k("M", "KeyM", 0x10), k(",", "KeyNe", 0x36), k(".", "KeyRu", 0x37), k("/", "KeyMe", 0x38),
]
private let common = functionRow + navigation + numpad + digits + qRow + aRow

private let pcBottomRow = [
    k("Ctrl", "KeyUSLeftControl", 0xE0, 1.25), k("Win", "KeyLeftPrimary", 0xE3, 1.25), k("Alt", "KeyLeftAuxiliary", 0xE2, 1.25),
    k("Space", "KeySpacebar", 0x2C, 6.25),
    k("Alt", "KeyRightAuxiliary", 0xE6, 1.25), k("Win", "KeyRightPrimary", 0xE7, 1.25), k("Menu", "KeyWINMenu", 0x65, 1.25),
    k("Ctrl", "KeyRightControl", 0xE4, 1.25),
]
/// Enter on ISO and JIS: 1.5u wide on the Q row, 1.25u on the A row.
private let tallEnter = Key(legend: "Enter", name: "KeyISOEnter", usage: .key(0x28), x: 13.5, y: 2.5, w: 1.5, h: 2, isoEnter: true)

let usBoard = Board(title: "US ANSI · 108 keys", keys: common
    + row(1.5, [k("`", "KeyHankakuZenkaku", 0x35)])
    + row(1.5, [k("-", "KeyHo", 0x2D), k("=", "KeyHe", 0x2E), k("Backspace", "KeyDeleteLeft", 0x2A, 2)], from: 11)
    + row(2.5, [k("Tab", "KeyTab", 0x2B, 1.5)])
    + row(2.5, [k("[", "KeyDakuten", 0x2F), k("]", "KeyHandakuten", 0x30), k("\\", "KeyMu", 0x31, 1.5)], from: 11.5)
    + row(3.5, [k("Caps", "KeyCapsLock", 0x39, 1.75)])
    + row(3.5, [k(";", "KeyRe", 0x33), k("'", "KeyKe", 0x34), k("Enter", "KeyISOEnter", 0x28, 2.25)], from: 10.75)
    + row(4.5, [k("Shift", "KeyLeftShift", 0xE1, 2.25)] + zLetters + [k("Shift", "KeyRightShift", 0xE5, 2.75)])
    + row(5.5, pcBottomRow))

let isoBoard = Board(title: "ISO · 109 keys", keys: common
    + row(1.5, [k("`", "KeyHankakuZenkaku", 0x35)])
    + row(1.5, [k("-", "KeyHo", 0x2D), k("=", "KeyHe", 0x2E), k("Backspace", "KeyDeleteLeft", 0x2A, 2)], from: 11)
    + row(2.5, [k("Tab", "KeyTab", 0x2B, 1.5)])
    + row(2.5, [k("[", "KeyDakuten", 0x2F), k("]", "KeyHandakuten", 0x30)], from: 11.5)
    + row(3.5, [k("Caps", "KeyCapsLock", 0x39, 1.75)])
    + row(3.5, [k(";", "KeyRe", 0x33), k("'", "KeyKe", 0x34), k("#", "KeyMu", 0x32)], from: 10.75)
    + [tallEnter]
    + row(4.5, [k("Shift", "KeyLeftShift", 0xE1, 1.25), k("\\", "KeyISOBackslash", 0x64)] + zLetters + [k("Shift", "KeyRightShift", 0xE5, 2.75)])
    + row(5.5, pcBottomRow))

let jisBoard = Board(title: "JIS · 113 keys", keys: common
    + row(1.5, [k("半/全", "KeyHankakuZenkaku", 0x35)])
    + row(1.5, [k("-", "KeyHo", 0x2D), k("^", "KeyHe", 0x2E), k("¥", "KeyLongKatakana", 0x89), k("BS", "KeyDeleteLeft", 0x2A)], from: 11)
    + row(2.5, [k("Tab", "KeyTab", 0x2B, 1.5)])
    + row(2.5, [k("@", "KeyDakuten", 0x2F), k("[", "KeyHandakuten", 0x30)], from: 11.5)
    + row(3.5, [k("英数", "KeyCapsLock", 0x39, 1.75)])
    + row(3.5, [k(";", "KeyRe", 0x33), k(":", "KeyKe", 0x34), k("]", "KeyMu", 0x32)], from: 10.75)
    + [tallEnter]
    + row(4.5, [k("Shift", "KeyLeftShift", 0xE1, 2.25)] + zLetters + [k("ろ", "KeyRo", 0x87), k("Shift", "KeyRightShift", 0xE5, 1.75)])
    + row(5.5, [
        k("Ctrl", "KeyUSLeftControl", 0xE0, 1.25), k("Win", "KeyLeftPrimary", 0xE3, 1.25), k("Alt", "KeyLeftAuxiliary", 0xE2, 1.25),
        k("無変換", "KeyJISMuhenkan", 0x8B, 1.25), k("Space", "KeySpacebar", 0x2C, 2.5), k("変換", "KeyJISHenkan", 0x8A, 1.25),
        k("カナ", "KeyJISKLangKorean", 0x88, 1.25),
        k("Alt", "KeyRightAuxiliary", 0xE6, 1.25), k("Win", "KeyRightPrimary", 0xE7, 1.25), k("Menu", "KeyWINMenu", 0x65, 1.25),
        k("Ctrl", "KeyRightControl", 0xE4, 1.25),
    ]))

let boards = [usBoard, isoBoard, jisBoard]

/// The key a usage belongs to, for the log: the US board's first, then ISO's, then JIS's.
let keyForUsage: [Usage: Key] = {
    var map: [Usage: Key] = [:]
    for board in boards { for key in board.keys where map[key.usage] == nil { map[key.usage] = key } }
    return map
}()

/// Usages that aren't on any of the three boards but have a canonical name.
let otherUsages: [Usage: (String, String)] = [
    .key(0x90): ("かな / 한/영 (LANG1)", "KeyJISMacKana"), .key(0x91): ("英数 / 한자 (LANG2)", "KeyJISMacEnglish"),
    .key(0x92): ("LANG3", "KeyLangThree"), .key(0x93): ("LANG4", "KeyLangFour"), .key(0x94): ("LANG5", "KeyLangFive"),
    .key(0x67): ("Keypad =", "KeyNumpadEquals"), .key(0x85): ("Keypad ,", "KeyNumpadComma"), .key(0x9C): ("Clear", "KeyClear"),
    .key(0x68): ("F13", "KeyFunctionThirteen"), .key(0x69): ("F14", "KeyFunctionFourteen"), .key(0x6A): ("F15", "KeyFunctionFifteen"),
    .key(0x6B): ("F16", "KeyFunctionSixteen"), .key(0x6C): ("F17", "KeyFunctionSeventeen"), .key(0x6D): ("F18", "KeyFunctionEighteen"),
    .key(0x6E): ("F19", "KeyFunctionNineteen"), .key(0x6F): ("F20", "KeyFunctionTwenty"),
    .consumer(0xCD): ("Play/Pause", "KeyMediaPlayPause"), .consumer(0xB5): ("Next Track", "KeyMediaNextTrack"),
    .consumer(0xB6): ("Previous Track", "KeyMediaPreviousTrack"), .consumer(0xB3): ("Fast Forward", "KeyMediaFastForward"),
    .consumer(0xB4): ("Rewind", "KeyMediaRewind"), .consumer(0xB8): ("Eject", "KeyEject"),
    .consumer(0x6F): ("Brightness Up", "KeyBrightnessUp"), .consumer(0x70): ("Brightness Down", "KeyBrightnessDown"),
]

/// (legend, canonical name) for the log; unknown usages get their hex.
func describe(_ usage: Usage) -> (String, String) {
    if let key = keyForUsage[usage] { return (key.legend, key.name) }
    if let other = otherUsages[usage] { return other }
    return ("?", "(no canonical name)")
}
