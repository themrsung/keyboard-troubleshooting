// Dubeolsik (두벌식 표준) composition, as the Microsoft IME Korean does it: one syllable in
// composition at a time, a final consonant moving to the next syllable when a vowel follows, and
// Backspace taking back one jamo at a time.

let choseong = Array("ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ")
let jungseong = Array("ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ")
let jongseong: [Character?] = [nil] + Array("ㄱㄲㄳㄴㄵㄶㄷㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅄㅅㅆㅇㅈㅊㅋㅌㅍㅎ")

let compoundVowels: [String: Character] = [
    "ㅗㅏ": "ㅘ", "ㅗㅐ": "ㅙ", "ㅗㅣ": "ㅚ", "ㅜㅓ": "ㅝ", "ㅜㅔ": "ㅞ", "ㅜㅣ": "ㅟ", "ㅡㅣ": "ㅢ",
]
let compoundFinals: [String: Character] = [
    "ㄱㅅ": "ㄳ", "ㄴㅈ": "ㄵ", "ㄴㅎ": "ㄶ", "ㄹㄱ": "ㄺ", "ㄹㅁ": "ㄻ", "ㄹㅂ": "ㄼ", "ㄹㅅ": "ㄽ",
    "ㄹㅌ": "ㄾ", "ㄹㅍ": "ㄿ", "ㄹㅎ": "ㅀ", "ㅂㅅ": "ㅄ",
]

/// The dubeolsik jamo on a key, by its US letter.
func dubeolsik(_ letter: Character, shift: Bool) -> Character? {
    let plain: [Character: Character] = [
        "q": "ㅂ", "w": "ㅈ", "e": "ㄷ", "r": "ㄱ", "t": "ㅅ", "y": "ㅛ", "u": "ㅕ", "i": "ㅑ", "o": "ㅐ", "p": "ㅔ",
        "a": "ㅁ", "s": "ㄴ", "d": "ㅇ", "f": "ㄹ", "g": "ㅎ", "h": "ㅗ", "j": "ㅓ", "k": "ㅏ", "l": "ㅣ",
        "z": "ㅋ", "x": "ㅌ", "c": "ㅊ", "v": "ㅍ", "b": "ㅠ", "n": "ㅜ", "m": "ㅡ",
    ]
    let shifted: [Character: Character] = ["q": "ㅃ", "w": "ㅉ", "e": "ㄸ", "r": "ㄲ", "t": "ㅆ", "o": "ㅒ", "p": "ㅖ"]
    let l = Character(letter.lowercased())
    return shift ? (shifted[l] ?? plain[l]) : plain[l]
}

func isVowel(_ j: Character) -> Bool { jungseong.contains(j) }

struct Syllable: Equatable {
    var cho: Character? = nil
    var jung: [Character] = []   // one vowel, or the two of a compound
    var jong: [Character] = []   // one consonant, or the two of a compound

    var isEmpty: Bool { cho == nil && jung.isEmpty }

    var vowel: Character? {
        switch jung.count {
        case 0: return nil
        case 1: return jung[0]
        default: return compoundVowels[String(jung)]
        }
    }
    var final: Character? {
        switch jong.count {
        case 0: return nil
        case 1: return jong[0]
        default: return compoundFinals[String(jong)]
        }
    }

    /// What the IME shows: a precomposed syllable, or a lone compatibility jamo.
    var text: String {
        guard let v = vowel else { return cho.map(String.init) ?? "" }
        guard let c = cho else { return String(v) }
        let ci = choseong.firstIndex(of: c)!, vi = jungseong.firstIndex(of: v)!
        let fi = jongseong.firstIndex(of: final) ?? 0
        return String(Character(Unicode.Scalar(0xAC00 + (ci * 21 + vi) * 28 + fi)!))
    }
}

struct HangulComposer {
    /// Every state the composition has been in since it started, for Backspace.
    private(set) var history: [Syllable] = []
    var current: Syllable { history.last ?? Syllable() }
    var isComposing: Bool { !current.isEmpty }

    /// Adds one jamo, and returns any text that leaves the composition as a result.
    mutating func input(_ j: Character) -> String {
        var s = current
        if isVowel(j) {
            if s.jung.isEmpty {
                s.jung = [j]
            } else if s.jong.isEmpty {
                if s.jung.count == 1, compoundVowels[String(s.jung) + String(j)] != nil {
                    s.jung.append(j)
                } else {
                    return start(Syllable(jung: [j]))
                }
            } else {
                // The final consonant (or the second of a compound) moves to the new syllable.
                var done = s
                let moving = done.jong.removeLast()
                history = [done]
                let committed = commit()
                history = [Syllable(cho: moving), Syllable(cho: moving, jung: [j])]
                return committed
            }
        } else {
            if s.cho == nil && s.jung.isEmpty {
                s.cho = j
            } else if s.cho == nil || s.jung.isEmpty {
                return start(Syllable(cho: j))
            } else if s.jong.isEmpty, jongseong.contains(j) {
                s.jong = [j]
            } else if s.jong.count == 1, compoundFinals[String(s.jong) + String(j)] != nil {
                s.jong.append(j)
            } else {
                return start(Syllable(cho: j))
            }
        }
        history.append(s)
        return ""
    }

    /// Takes back the last jamo. False when there was nothing in composition.
    mutating func backspace() -> Bool {
        guard isComposing else { return false }
        history.removeLast()
        return true
    }

    /// Ends the composition, returning its text.
    mutating func commit() -> String {
        let text = current.text
        history = []
        return text
    }

    private mutating func start(_ next: Syllable) -> String {
        let committed = commit()
        history = [next]
        return committed
    }
}
