// The rules and groups: pure logic, checked by `--selftest`.
import Foundation

enum Rule: Equatable {
    case or, and, xor, one
    case atLeast(Int)

    /// Whether the output is held, with `held` of `total` members down.
    func holds(_ held: Int, of total: Int) -> Bool {
        switch self {
        case .or: return held >= 1
        case .and: return held == total
        case .xor: return held % 2 == 1
        case .one: return held == 1
        case .atLeast(let n): return held >= n
        }
    }
}

enum Transition: Equatable { case down, up }

/// A group being typed on: which members are held, and whether the output is.
struct Group {
    let members: [UInt16]
    let output: UInt16
    let rule: Rule
    private(set) var held: Set<UInt16> = []
    private(set) var active = false

    init(members: [UInt16], output: UInt16, rule: Rule) {
        self.members = members
        self.output = output
        self.rule = rule
    }

    /// A member went down or up (not a repeat). Returns the output's change, if any. A second down
    /// for a member already held, or an up for one not held, changes nothing.
    mutating func handle(_ code: UInt16, down: Bool) -> Transition? {
        guard members.contains(code) else { return nil }
        if down { held.insert(code) } else { held.remove(code) }
        let now = rule.holds(held.count, of: members.count)
        defer { active = now }
        if now && !active { return .down }
        if !now && active { return .up }
        return nil
    }
}

// MARK: - Saved groups

enum RuleKind: String, Codable, CaseIterable, Identifiable {
    case or, and, xor, one, nOfM
    var id: String { rawValue }
    var title: String {
        switch self {
        case .or: return "Any held (OR)"
        case .and: return "All held (AND)"
        case .xor: return "Odd number held (XOR)"
        case .one: return "Exactly one held"
        case .nOfM: return "At least N of M held"
        }
    }
}

/// A group as the user set it up (saved between launches).
struct GroupConfig: Codable, Identifiable, Equatable {
    var id = UUID()
    var members: [UInt16] = []
    var output: UInt16?
    var rule: RuleKind = .or
    var n = 2

    var resolvedRule: Rule {
        switch rule {
        case .or: return .or
        case .and: return .and
        case .xor: return .xor
        case .one: return .one
        case .nOfM: return .atLeast(n)
        }
    }

    /// Why this group can't be used (nil: it can). `earlier`: the groups listed before it, which
    /// keep a member that two groups share.
    func problem(earlier: [GroupConfig]) -> String? {
        if members.count < 2 { return "Record at least two keys." }
        guard let output else { return "Record the key it sends." }
        if members.contains(output) { return "It can't send one of its own keys." }
        if rule == .nOfM && !(1...members.count).contains(n) { return "N must be 1 to \(members.count)." }
        let taken = Set(earlier.flatMap(\.members))
        if let dup = members.first(where: taken.contains) { return "\(keyName(dup)) is already in another group." }
        return nil
    }

    var group: Group? {
        guard let output else { return nil }
        return Group(members: members, output: output, rule: resolvedRule)
    }
}

// MARK: - Key names (macOS virtual key codes)

let KEYS: [String: UInt16] = {
    var k: [String: UInt16] = [
        "Space": 49, "Return": 36, "Tab": 48, "Delete": 51, "Esc": 53, "Fwd Delete": 117,
        "英数": 102, "かな": 104, "¥": 93, "ろ": 94, "-": 27, "^": 24, "@": 33, "[": 30, "]": 42,
        ";": 41, ":": 39, ",": 43, ".": 47, "/": 44,
        "←": 123, "→": 124, "↓": 125, "↑": 126, "Home": 115, "End": 119, "Page Up": 116, "Page Down": 121,
        "F1": 122, "F2": 120, "F3": 99, "F4": 118, "F5": 96, "F6": 97, "F7": 98, "F8": 100, "F9": 101, "F10": 109,
        "F11": 103, "F12": 111, "F13": 105, "F14": 107, "F15": 113, "F16": 106, "F17": 64, "F18": 79, "F19": 80, "F20": 90,
    ]
    let letters: [(String, UInt16)] = [("A", 0), ("S", 1), ("D", 2), ("F", 3), ("H", 4), ("G", 5), ("Z", 6), ("X", 7),
        ("C", 8), ("V", 9), ("B", 11), ("Q", 12), ("W", 13), ("E", 14), ("R", 15), ("Y", 16), ("T", 17), ("O", 31),
        ("U", 32), ("I", 34), ("P", 35), ("L", 37), ("J", 38), ("K", 40), ("N", 45), ("M", 46),
        ("1", 18), ("2", 19), ("3", 20), ("4", 21), ("5", 23), ("6", 22), ("7", 26), ("8", 28), ("9", 25), ("0", 29)]
    for (n, c) in letters { k[n] = c }
    return k
}()

func keyName(_ code: UInt16) -> String {
    KEYS.first { $0.value == code }.map(\.key) ?? "key \(code)"
}

func keyCode(_ name: String) -> UInt16? {
    KEYS.first { $0.key.lowercased() == name.lowercased() }?.value
}

// MARK: - Self-test

func selftest() -> Bool {
    var failures = 0
    func check(_ name: String, _ members: [String], _ rule: Rule, _ steps: [(String, Bool, Transition?)]) {
        var g = Group(members: members.map { keyCode($0)! }, output: keyCode("Space")!, rule: rule)
        for (i, (key, down, want)) in steps.enumerated() {
            let got = g.handle(keyCode(key)!, down: down)
            if got != want {
                print("FAIL \(name), step \(i + 1) (\(key) \(down ? "down" : "up")): got \(String(describing: got)), want \(String(describing: want))")
                failures += 1
            }
        }
        if g.active { print("FAIL \(name): output still held at the end"); failures += 1 }
    }
    // OR: the bar stays down until the last switch is released (the case plain remapping gets wrong).
    check("or", ["F13", "F14"], .or, [("F13", true, .down), ("F14", true, nil), ("F13", false, nil), ("F14", false, .up)])
    check("or, repeated down ignored", ["A", "S"], .or, [("A", true, .down), ("A", true, nil), ("A", false, .up)])
    check("or, stray up ignored", ["A", "S"], .or, [("S", false, nil), ("A", true, .down), ("A", false, .up)])
    check("and", ["A", "S"], .and, [("A", true, nil), ("S", true, .down), ("A", false, .up), ("S", false, nil)])
    check("all of 3", ["A", "S", "D"], .and, [("A", true, nil), ("S", true, nil), ("D", true, .down),
                                              ("S", false, .up), ("A", false, nil), ("D", false, nil)])
    check("xor", ["A", "S"], .xor, [("A", true, .down), ("S", true, .up), ("A", false, .down), ("S", false, .up)])
    check("xor of 3 (odd)", ["A", "S", "D"], .xor, [("A", true, .down), ("S", true, .up), ("D", true, .down),
                                                    ("A", false, .up), ("S", false, .down), ("D", false, .up)])
    check("one of 3", ["A", "S", "D"], .one, [("A", true, .down), ("S", true, .up), ("D", true, nil),
                                              ("A", false, nil), ("S", false, .down), ("D", false, .up)])
    check("2 of 3", ["A", "S", "D"], .atLeast(2), [("A", true, nil), ("S", true, .down), ("D", true, nil),
                                                   ("A", false, nil), ("S", false, .up), ("D", false, nil)])
    check("3 of 4", ["A", "S", "D", "F"], .atLeast(3), [("A", true, nil), ("S", true, nil), ("D", true, .down),
                                                        ("F", true, nil), ("A", false, nil), ("S", false, .up),
                                                        ("D", false, nil), ("F", false, nil)])
    let a = keyCode("A")!, s = keyCode("S")!, d = keyCode("D")!, space = keyCode("Space")!
    let problems: [(GroupConfig, [GroupConfig], String)] = [
        (GroupConfig(members: [a], output: space), [], "one member"),
        (GroupConfig(members: [a, s], output: nil), [], "no output"),
        (GroupConfig(members: [a, s], output: a), [], "output is a member"),
        (GroupConfig(members: [a, s], output: space, rule: .nOfM, n: 3), [], "N > M"),
        (GroupConfig(members: [a, s], output: space), [GroupConfig(members: [s, d], output: space)], "shared member"),
    ]
    for (g, earlier, why) in problems where g.problem(earlier: earlier) == nil {
        print("FAIL: a group with \(why) should be refused"); failures += 1
    }
    if GroupConfig(members: [a, s], output: space).problem(earlier: []) != nil { print("FAIL: a good group was refused"); failures += 1 }
    print(failures == 0 ? "self-test passed" : "self-test: \(failures) failure(s)")
    return failures == 0
}
