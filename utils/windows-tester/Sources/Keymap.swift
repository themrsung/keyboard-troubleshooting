// How a key that macOS reports arrives on Windows: scan code (set 1), virtual-key code, and what
// the US / Korean layout types with it. macOS hides some PC keys behind others (Print Screen is
// F13, Insert is Help), so those entries say which key they most likely were.

struct WinKey {
    let name: String       // the key, as printed on a PC keyboard
    let scan: String       // set 1 make code, E0 for extended keys
    let vk: UInt8
    let vkName: String
    var char: Character? = nil       // unshifted, US layout (the Korean layout's Latin keys are the same)
    var shifted: Character? = nil
    var note: String? = nil
    var isLetter: Bool { char.map { $0.isLetter } ?? false }
}

enum Side { case left, right }
enum Modifier { case control, shift, alt, win }

/// Windows modifier for a macOS modifier key code, if it is one. ⌘ is Windows, ⌥ is Alt.
func modifier(for keyCode: UInt16) -> (Modifier, Side, UInt64)? {
    // Device-dependent flag bits, so the two sides are told apart (IOLLEvent.h, NX_DEVICE*KEYMASK).
    switch keyCode {
    case 0x3B: return (.control, .left, 0x0001)
    case 0x3E: return (.control, .right, 0x2000)
    case 0x38: return (.shift, .left, 0x0002)
    case 0x3C: return (.shift, .right, 0x0004)
    case 0x3A: return (.alt, .left, 0x0020)
    case 0x3D: return (.alt, .right, 0x0040)
    case 0x37: return (.win, .left, 0x0008)
    case 0x36: return (.win, .right, 0x0010)
    default: return nil
    }
}

private func k(_ name: String, _ scan: String, _ vk: UInt8, _ vkName: String, _ c: Character? = nil,
               _ s: Character? = nil, note: String? = nil) -> WinKey {
    WinKey(name: name, scan: scan, vk: vk, vkName: vkName, char: c, shifted: s, note: note)
}
private func letter(_ l: Character, _ scan: String) -> WinKey {
    let u = Character(l.uppercased())
    return k(String(u), scan, u.asciiValue!, "VK_\(u)", l, u)
}

/// macOS virtual key code (kVK_*) → Windows key.
let winKeys: [UInt16: WinKey] = [
    0x00: letter("a", "1E"), 0x01: letter("s", "1F"), 0x02: letter("d", "20"), 0x03: letter("f", "21"),
    0x04: letter("h", "23"), 0x05: letter("g", "22"), 0x06: letter("z", "2C"), 0x07: letter("x", "2D"),
    0x08: letter("c", "2E"), 0x09: letter("v", "2F"), 0x0B: letter("b", "30"), 0x0C: letter("q", "10"),
    0x0D: letter("w", "11"), 0x0E: letter("e", "12"), 0x0F: letter("r", "13"), 0x10: letter("y", "15"),
    0x11: letter("t", "14"), 0x1F: letter("o", "18"), 0x20: letter("u", "16"), 0x22: letter("i", "17"),
    0x23: letter("p", "19"), 0x25: letter("l", "26"), 0x26: letter("j", "24"), 0x28: letter("k", "25"),
    0x2D: letter("n", "31"), 0x2E: letter("m", "32"),

    0x12: k("1", "02", 0x31, "VK_1", "1", "!"), 0x13: k("2", "03", 0x32, "VK_2", "2", "@"),
    0x14: k("3", "04", 0x33, "VK_3", "3", "#"), 0x15: k("4", "05", 0x34, "VK_4", "4", "$"),
    0x17: k("5", "06", 0x35, "VK_5", "5", "%"), 0x16: k("6", "07", 0x36, "VK_6", "6", "^"),
    0x1A: k("7", "08", 0x37, "VK_7", "7", "&"), 0x1C: k("8", "09", 0x38, "VK_8", "8", "*"),
    0x19: k("9", "0A", 0x39, "VK_9", "9", "("), 0x1D: k("0", "0B", 0x30, "VK_0", "0", ")"),
    0x1B: k("-", "0C", 0xBD, "VK_OEM_MINUS", "-", "_"), 0x18: k("=", "0D", 0xBB, "VK_OEM_PLUS", "=", "+"),
    0x21: k("[", "1A", 0xDB, "VK_OEM_4", "[", "{"), 0x1E: k("]", "1B", 0xDD, "VK_OEM_6", "]", "}"),
    0x2A: k("\\ (₩)", "2B", 0xDC, "VK_OEM_5", "\\", "|"), 0x29: k(";", "27", 0xBA, "VK_OEM_1", ";", ":"),
    0x27: k("'", "28", 0xDE, "VK_OEM_7", "'", "\""), 0x32: k("`", "29", 0xC0, "VK_OEM_3", "`", "~"),
    0x2B: k(",", "33", 0xBC, "VK_OEM_COMMA", ",", "<"), 0x2F: k(".", "34", 0xBE, "VK_OEM_PERIOD", ".", ">"),
    0x2C: k("/", "35", 0xBF, "VK_OEM_2", "/", "?"),

    0x35: k("Esc", "01", 0x1B, "VK_ESCAPE"),
    0x33: k("Backspace", "0E", 0x08, "VK_BACK"),
    0x30: k("Tab", "0F", 0x09, "VK_TAB", "\t", "\t"),
    0x24: k("Enter", "1C", 0x0D, "VK_RETURN", "\r", "\r"),
    0x31: k("Space", "39", 0x20, "VK_SPACE", " ", " "),
    0x39: k("Caps Lock", "3A", 0x14, "VK_CAPITAL"),

    0x7A: k("F1", "3B", 0x70, "VK_F1"), 0x78: k("F2", "3C", 0x71, "VK_F2"), 0x63: k("F3", "3D", 0x72, "VK_F3"),
    0x76: k("F4", "3E", 0x73, "VK_F4"), 0x60: k("F5", "3F", 0x74, "VK_F5"), 0x61: k("F6", "40", 0x75, "VK_F6"),
    0x62: k("F7", "41", 0x76, "VK_F7"), 0x64: k("F8", "42", 0x77, "VK_F8"), 0x65: k("F9", "43", 0x78, "VK_F9"),
    0x6D: k("F10", "44", 0x79, "VK_F10"), 0x67: k("F11", "57", 0x7A, "VK_F11"), 0x6F: k("F12", "58", 0x7B, "VK_F12"),
    0x69: k("Print Screen", "E0 37", 0x2C, "VK_SNAPSHOT", note: "macOS reports Print Screen and F13 alike"),
    0x6B: k("Scroll Lock", "46", 0x91, "VK_SCROLL", note: "macOS reports Scroll Lock and F14 alike"),
    0x71: k("Pause", "E1 1D 45", 0x13, "VK_PAUSE", note: "macOS reports Pause and F15 alike"),
    0x6A: k("F16", "67", 0x7F, "VK_F16"), 0x40: k("F17", "68", 0x80, "VK_F17"), 0x4F: k("F18", "69", 0x81, "VK_F18"),
    0x50: k("F19", "6A", 0x82, "VK_F19"), 0x5A: k("F20", "6B", 0x83, "VK_F20"),

    0x72: k("Insert", "E0 52", 0x2D, "VK_INSERT", note: "macOS reports Insert as Help"),
    0x75: k("Delete", "E0 53", 0x2E, "VK_DELETE"),
    0x73: k("Home", "E0 47", 0x24, "VK_HOME"), 0x77: k("End", "E0 4F", 0x23, "VK_END"),
    0x74: k("Page Up", "E0 49", 0x21, "VK_PRIOR"), 0x79: k("Page Down", "E0 51", 0x22, "VK_NEXT"),
    0x7B: k("←", "E0 4B", 0x25, "VK_LEFT"), 0x7C: k("→", "E0 4D", 0x27, "VK_RIGHT"),
    0x7D: k("↓", "E0 50", 0x28, "VK_DOWN"), 0x7E: k("↑", "E0 48", 0x26, "VK_UP"),
    0x6E: k("Menu", "E0 5D", 0x5D, "VK_APPS", note: "the PC Application key, as macOS numbers it"),

    0x47: k("Num Lock", "45", 0x90, "VK_NUMLOCK", note: "macOS reports Num Lock as keypad Clear"),
    0x4B: k("Keypad /", "E0 35", 0x6F, "VK_DIVIDE", "/", "/"),
    0x43: k("Keypad *", "37", 0x6A, "VK_MULTIPLY", "*", "*"),
    0x4E: k("Keypad -", "4A", 0x6D, "VK_SUBTRACT", "-", "-"),
    0x45: k("Keypad +", "4E", 0x6B, "VK_ADD", "+", "+"),
    0x4C: k("Keypad Enter", "E0 1C", 0x0D, "VK_RETURN", "\r", "\r"),
    0x51: k("Keypad =", "59", 0x92, "VK_OEM_NEC_EQUAL", note: "not on a PC 104-key board"),
    0x52: k("Keypad 0", "52", 0x60, "VK_NUMPAD0", "0", "0"), 0x53: k("Keypad 1", "4F", 0x61, "VK_NUMPAD1", "1", "1"),
    0x54: k("Keypad 2", "50", 0x62, "VK_NUMPAD2", "2", "2"), 0x55: k("Keypad 3", "51", 0x63, "VK_NUMPAD3", "3", "3"),
    0x56: k("Keypad 4", "4B", 0x64, "VK_NUMPAD4", "4", "4"), 0x57: k("Keypad 5", "4C", 0x65, "VK_NUMPAD5", "5", "5"),
    0x58: k("Keypad 6", "4D", 0x66, "VK_NUMPAD6", "6", "6"), 0x59: k("Keypad 7", "47", 0x67, "VK_NUMPAD7", "7", "7"),
    0x5B: k("Keypad 8", "48", 0x68, "VK_NUMPAD8", "8", "8"), 0x5C: k("Keypad 9", "49", 0x69, "VK_NUMPAD9", "9", "9"),
    0x41: k("Keypad .", "53", 0x6E, "VK_DECIMAL", ".", "."),

    // USB LANG1 / LANG2, which a Mac names かな / 英数, are the Korean keyboard's 한/영 and 한자.
    0x68: k("한/영", "F2", 0x15, "VK_HANGUL", note: "USB LANG1 (かな on a Mac)"),
    0x66: k("한자", "F1", 0x19, "VK_HANJA", note: "USB LANG2 (英数 on a Mac)"),
    0x5D: k("¥ (JIS)", "7D", 0xDC, "VK_OEM_5?", note: "USB International3; its VK on the Korean layout is unverified"),
    0x5E: k("ろ (JIS)", "73", 0xC1, "VK_ABNT_C1?", note: "USB International1; its VK on the Korean layout is unverified"),
    0x0A: k("ISO §", "56", 0xE2, "VK_OEM_102", note: "the ISO key left of Z"),

    // Modifiers. Generic VK first in messages, as Windows sends them (VK_CONTROL with the side in lParam).
    0x3B: k("Left Control", "1D", 0x11, "VK_CONTROL (VK_LCONTROL)"),
    0x3E: k("Right Control", "E0 1D", 0x11, "VK_CONTROL (VK_RCONTROL)"),
    0x38: k("Left Shift", "2A", 0x10, "VK_SHIFT (VK_LSHIFT)"),
    0x3C: k("Right Shift", "36", 0x10, "VK_SHIFT (VK_RSHIFT)"),
    0x3A: k("Left Alt", "38", 0x12, "VK_MENU (VK_LMENU)"),
    0x3D: k("Right Alt", "E0 38", 0x12, "VK_MENU (VK_RMENU)"),
    0x37: k("Left Windows", "E0 5B", 0x5B, "VK_LWIN"),
    0x36: k("Right Windows", "E0 5C", 0x5C, "VK_RWIN"),
    0x3F: k("Fn (Mac)", "-", 0, "-", note: "a Mac's Fn; a PC board's Fn never leaves the keyboard"),
]

/// Keys with NumLock off, keypad → navigation.
let numLockOff: [UInt16: (String, UInt8, String)] = [
    0x52: ("Insert", 0x2D, "VK_INSERT"), 0x53: ("End", 0x23, "VK_END"), 0x54: ("↓", 0x28, "VK_DOWN"),
    0x55: ("Page Down", 0x22, "VK_NEXT"), 0x56: ("←", 0x25, "VK_LEFT"), 0x57: ("(nothing)", 0x0C, "VK_CLEAR"),
    0x58: ("→", 0x27, "VK_RIGHT"), 0x59: ("Home", 0x24, "VK_HOME"), 0x5B: ("↑", 0x26, "VK_UP"),
    0x5C: ("Page Up", 0x21, "VK_PRIOR"), 0x41: ("Delete", 0x2E, "VK_DELETE"),
]

/// Media keys, which macOS sends as system-defined events (NX_KEYTYPE_*) rather than key events.
let mediaKeys: [Int: (String, UInt8, String)] = [
    0: ("Volume Up", 0xAF, "VK_VOLUME_UP"), 1: ("Volume Down", 0xAE, "VK_VOLUME_DOWN"),
    7: ("Mute", 0xAD, "VK_VOLUME_MUTE"), 16: ("Play/Pause", 0xB3, "VK_MEDIA_PLAY_PAUSE"),
    17: ("Next Track", 0xB0, "VK_MEDIA_NEXT_TRACK"), 18: ("Previous Track", 0xB1, "VK_MEDIA_PREV_TRACK"),
    19: ("Next Track", 0xB0, "VK_MEDIA_NEXT_TRACK"), 20: ("Previous Track", 0xB1, "VK_MEDIA_PREV_TRACK"),
    2: ("Brightness Up", 0, "(no VK: HID consumer page)"), 3: ("Brightness Down", 0, "(no VK: HID consumer page)"),
]
