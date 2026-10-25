// What a Windows app with the Microsoft IME Korean would see for each key: the window messages,
// what the IME does with the key, and the text that ends up in a plain edit control.

import Foundation

/// The Korean keyboard type, set by Windows's `LayerDriver KOR` value.
enum KoreanType: Int, CaseIterable {
    case type1, type2, type3
    var label: String {
        switch self {
        case .type1: return "Type 1 (kbd101a): Right Alt = 한/영, Right Ctrl = 한자"
        case .type2: return "Type 2 (kbd103): dedicated 한/영 and 한자 keys only"
        case .type3: return "Type 3 (kbd101c): Shift+Space = 한/영, Ctrl+Space = 한자"
        }
    }
}

/// The macOS key codes (Carbon kVK_*) the simulator's logic looks at by number.
private enum KVK {
    static let capsLock: UInt16 = 0x39       // kVK_CapsLock
    static let space: UInt16 = 0x31          // kVK_Space
    static let jisKana: UInt16 = 0x68        // kVK_JIS_Kana: USB LANG1, 한/영
    static let jisEisu: UInt16 = 0x66        // kVK_JIS_Eisu: USB LANG2, 한자
    static let rightOption: UInt16 = 0x3D    // kVK_RightOption: Right Alt
    static let rightControl: UInt16 = 0x3E   // kVK_RightControl
}

final class Simulator {
    var koreanType = KoreanType.type1
    private(set) var hangulMode = false
    private(set) var capsLock = false
    private(set) var numLock = true
    private(set) var scrollLock = false
    private(set) var text = ""
    private(set) var composer = HangulComposer()

    /// Held modifiers, by macOS key code, only while they act as modifiers on Windows.
    private var held: [UInt16: (Modifier, Side)] = [:]
    /// Keys Type 1 turned into 한/영 or 한자, so their release isn't taken for a modifier's.
    private var remappedDown: Set<UInt16> = []
    /// For telling a lone tap of Alt or Windows (menu bar, Start) from a chord.
    private var lastDown: UInt16? = nil
    private var log: (String) -> Void

    init(log: @escaping (String) -> Void) { self.log = log }

    var ctrl: Bool { held.values.contains { $0.0 == .control } }
    var shift: Bool { held.values.contains { $0.0 == .shift } }
    var alt: Bool { held.values.contains { $0.0 == .alt } }
    var win: Bool { held.values.contains { $0.0 == .win } }

    var modifierPrefix: String {
        [(ctrl, "Ctrl"), (shift, "Shift"), (alt, "Alt"), (win, "Win")].filter { $0.0 }.map { $0.1 + "+" }.joined()
    }

    var status: String {
        let held = self.held.isEmpty ? "-" : modifierPrefix.dropLast().description
        return "IME: \(hangulMode ? "한 (Korean)" : "A (English)")   Caps Lock: \(capsLock ? "on" : "off")   "
            + "Num Lock: \(numLock ? "on" : "off")   Scroll Lock: \(scrollLock ? "on" : "off")   held: \(held)"
    }

    func clear() {
        text = ""
        composer = HangulComposer()
    }

    // MARK: Events from macOS

    func flagsChanged(keyCode: UInt16, flags: UInt64, capsLockOn: Bool) {
        if keyCode == KVK.capsLock {
            lastDown = keyCode
            capsLock = capsLockOn
            line("↓↑", winKeys[KVK.capsLock]!, message: "WM_KEYDOWN/UP", detail: "Caps Lock \(capsLock ? "on" : "off")")
            return
        }
        guard let (mod, side, bit) = modifier(for: keyCode), let key = winKeys[keyCode] else {
            if let key = winKeys[keyCode] { line("··", key, message: "-", detail: key.note ?? "") }
            return
        }
        let down = flags & bit != 0
        if down {
            if koreanType == .type1, let lang = type1Language(keyCode) {
                remappedDown.insert(keyCode)
                lastDown = keyCode
                pressLanguageKey(lang, from: key, scan: key.scan)
                return
            }
            held[keyCode] = (mod, side)
            lastDown = keyCode
            let message = mod == .alt && !ctrl ? "WM_SYSKEYDOWN" : "WM_KEYDOWN"
            line("↓", key, message: message, detail: "")
        } else {
            if remappedDown.remove(keyCode) != nil {
                line("↑", key, message: "WM_KEYUP", detail: "(\(type1Language(keyCode)!.vkName))")
                return
            }
            held[keyCode] = nil
            var detail = ""
            if lastDown == keyCode {
                if mod == .alt { detail = "a lone Alt: activates the window's menu bar" }
                if mod == .win { detail = "a lone Windows key: opens Start" }
            }
            let message = mod == .alt && !ctrl ? "WM_SYSKEYUP" : "WM_KEYUP"
            line("↑", key, message: message, detail: detail)
        }
    }

    func keyDown(keyCode: UInt16, isRepeat: Bool) {
        lastDown = keyCode
        guard var key = winKeys[keyCode] else {
            log(String(format: "↓  macOS key 0x%02X: no Windows equivalent known", keyCode))
            return
        }
        if !numLock, let nav = numLockOff[keyCode] {
            key = WinKey(name: "\(key.name) → \(nav.0)", canonical: "\(key.canonical) → \(nav.1)", scan: key.scan,
                         vk: nav.2, vkName: nav.3, note: "Num Lock is off")
        }
        let r = isRepeat ? " (repeat)" : ""

        // Language keys: dedicated ones, and the combinations a keyboard type adds.
        if key.vk == 0x15 || key.vk == 0x19 {
            pressLanguageKey(key, from: key, scan: key.scan)
            return
        }
        if koreanType == .type3, keyCode == KVK.space, shift || ctrl, !alt, !win {
            pressLanguageKey(winKeys[shift ? KVK.jisKana : KVK.jisEisu]!, from: key, scan: key.scan)
            return
        }

        if key.vk == 0x90 { numLock.toggle() }
        if key.vk == 0x91 { scrollLock.toggle() }
        let message = (alt && !ctrl) || (key.vk == 0x79 && !ctrl) ? "WM_SYSKEYDOWN" : "WM_KEYDOWN"
        let shortcut = ctrl || alt || win

        // The IME takes letters and Backspace while composing; the app sees VK_PROCESSKEY.
        if hangulMode && !shortcut {
            if key.isLetter && !capsLock, let jamo = dubeolsik(key.char!, shift: shift) {
                let was = composer.current.text
                let committed = composer.input(jamo)
                line("↓", key, message: "WM_KEYDOWN VK_PROCESSKEY" + r, detail: "IME takes it: \(jamo)", chord: true)
                emitComposition(from: was, committed: committed)
                return
            }
            if key.vk == 0x08 && composer.isComposing {
                let was = composer.current.text
                _ = composer.backspace()
                line("↓", key, message: "WM_KEYDOWN VK_PROCESSKEY" + r, detail: "IME takes back a jamo")
                emitComposition(from: was, committed: "")
                return
            }
        }

        // Anything else ends the composition first, then reaches the app.
        if composer.isComposing {
            let was = composer.current.text
            emitComposition(from: was, committed: composer.commit(), reason: "\(modifierPrefix)\(key.name)")
        }
        line("↓", key, message: message + r, detail: shellNote(key) ?? key.note ?? "", chord: true)
        type(key)
    }

    func keyUp(keyCode: UInt16) {
        guard let key = winKeys[keyCode] else { return }
        let message = alt && !ctrl ? "WM_SYSKEYUP" : "WM_KEYUP"
        line("↑", key, message: message, detail: "")
    }

    func media(_ code: Int, down: Bool) {
        guard let (name, canonical, vk, vkName) = mediaKeys[code] else {
            log("\(down ? "↓" : "↑")  media key \(code): no Windows equivalent known")
            return
        }
        let vkText = vk == 0 ? vkName : String(format: "%@ (0x%02X)", vkName, vk)
        log("\(down ? "↓" : "↑")  \(pad(name, 22))  \(pad(canonical, 24))  HID consumer page   \(pad(vkText, 34))  \(down ? "WM_KEYDOWN" : "WM_KEYUP")")
    }

    // MARK: Pieces

    private func type1Language(_ keyCode: UInt16) -> WinKey? {
        switch keyCode {
        case KVK.rightOption: return winKeys[KVK.jisKana]    // Right Alt → 한/영
        case KVK.rightControl: return winKeys[KVK.jisEisu]   // Right Control → 한자
        default: return nil
        }
    }

    private func pressLanguageKey(_ lang: WinKey, from key: WinKey, scan: String) {
        // The canonical name stays the key pressed: Right Alt acting as 한/영 is still KeyRightAuxiliary.
        let shown = WinKey(name: key.name == lang.name ? lang.name : "\(key.name) → \(lang.name)",
                           canonical: key.canonical, scan: scan, vk: lang.vk, vkName: lang.vkName)
        if lang.vk == 0x15 {
            let was = composer.current.text
            if composer.isComposing { emitComposition(from: was, committed: composer.commit(), reason: "한/영") }
            hangulMode.toggle()
            line("↓", shown, message: "WM_KEYDOWN", detail: "IME: now \(hangulMode ? "한 (Korean)" : "A (English)")")
        } else if composer.isComposing {
            line("↓", shown, message: "WM_KEYDOWN VK_PROCESSKEY",
                 detail: "IME: hanja candidates for \(composer.current.text) (not simulated)")
        } else {
            line("↓", shown, message: "WM_KEYDOWN", detail: "IME: nothing in composition, nothing to convert")
        }
    }

    private func emitComposition(from was: String, committed: String, reason: String? = nil) {
        let now = composer.current.text
        let ended = reason.map { ", ended by \($0)" } ?? ""
        if !committed.isEmpty { text += committed }
        switch (was.isEmpty, committed.isEmpty, now.isEmpty) {
        case (true, true, false):
            log("       WM_IME_STARTCOMPOSITION, WM_IME_COMPOSITION (composing \(now))")
        case (_, false, false):
            log("       WM_IME_COMPOSITION (result \(committed), composing \(now))  →  WM_IME_CHAR / WM_CHAR \(committed)")
        case (_, false, true):
            log("       WM_IME_COMPOSITION (result \(committed))\(ended)  →  WM_IME_CHAR / WM_CHAR \(committed)")
            log("       WM_IME_ENDCOMPOSITION")
        case (false, true, true):
            log("       WM_IME_COMPOSITION (empty), WM_IME_ENDCOMPOSITION")
        case (_, true, false):
            log("       WM_IME_COMPOSITION (composing \(now))")
        default:
            break
        }
    }

    /// What the key types into a plain edit control, outside the IME.
    private func type(_ key: WinKey) {
        if win { return }
        if ctrl, !alt, key.isLetter {
            let code = Int(key.vk) - 0x40
            log(String(format: "       WM_CHAR 0x%02X (Ctrl+%@)", code, key.name))
            return
        }
        if key.vk == 0x08 {
            log("       WM_CHAR 0x08 (Backspace)")
            if !text.isEmpty { text.removeLast() }
            return
        }
        guard var c = (shift ? key.shifted : key.char) else { return }
        if key.isLetter && capsLock { c = Character(shift ? c.lowercased() : c.uppercased()) }
        if alt && !ctrl {
            log("       WM_SYSCHAR \(visible(c))")
            return
        }
        if ctrl { return }
        log("       WM_CHAR \(visible(c))")
        text.append(c == "\r" ? "\n" : c)
    }

    /// Combinations Windows itself takes before the app.
    private func shellNote(_ key: WinKey) -> String? {
        let combo = modifierPrefix + key.name
        let notes: [String: String] = [
            "Win+Space": "Windows: switches the input language", "Win+L": "Windows: locks",
            "Win+D": "Windows: shows the desktop", "Win+E": "Windows: File Explorer", "Win+R": "Windows: Run",
            "Win+Tab": "Windows: Task View", "Win+V": "Windows: clipboard history", "Win+.": "Windows: emoji panel",
            "Shift+Win+S": "Windows: Snipping Tool", "Alt+Tab": "Windows: switches windows",
            "Alt+F4": "Windows: closes the window", "Ctrl+Shift+Esc": "Windows: Task Manager",
            "Print Screen": "Windows 11: may open Snipping Tool (a setting)",
        ]
        return notes[combo]
    }

    private func line(_ arrow: String, _ key: WinKey, message: String, detail: String, chord: Bool = false) {
        let vk = key.vk == 0 ? key.vkName : String(format: "%@ (0x%02X)", key.vkName, key.vk)
        let name = chord ? modifierPrefix + key.name : key.name
        log("\(arrow)  \(pad(name, 22))  \(pad(key.canonical, 24))  sc \(pad(key.scan, 9))  \(pad(vk, 34))  \(pad(message, 30))  \(detail)")
    }
}

private func pad(_ s: String, _ n: Int) -> String { s.count >= n ? s : s + String(repeating: " ", count: n - s.count) }
private func visible(_ c: Character) -> String {
    switch c {
    case "\r": return "0x0D (Enter)"
    case "\t": return "0x09 (Tab)"
    case " ": return "' '"
    default: return "'\(c)'"
    }
}
