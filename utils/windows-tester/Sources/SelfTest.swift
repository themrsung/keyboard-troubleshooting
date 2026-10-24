// `WindowsTester.app/Contents/MacOS/WindowsTester --selftest`: the composer against known results.

func selfTest() -> Bool {
    // Keys as US letters (capital for Shift), "<" for Backspace, " " to commit.
    // The result is the committed text, then the composition in brackets.
    let cases: [(String, String)] = [
        ("dkssudgktpdy", "안녕하세[요]"), ("ekfrdmf", "닭[을]"), ("rhk", "[과]"), ("rhk<", "[고]"),
        ("ekfr<<", "[다]"), ("rtk", "ㄱ[사]"), ("rkqt", "[값]"), ("rkqtdl", "값[이]"), ("rkqtk", "갑[사]"),
        ("Rk", "[까]"), ("rkR", "[갂]"), ("hk", "[ㅘ]"), ("hkr", "ㅘ[ㄱ]"), ("dho", "[왜]"), ("dml", "[의]"),
        ("rk<<<", "[]"), ("rk ", "가 []"), ("rkfk<", "가[ㄹ]"), ("dkEk", "아[따]"), ("rkE", "가[ㄸ]"),
    ]
    var failed = 0
    for (keys, want) in cases {
        var composer = HangulComposer()
        var out = ""
        for c in keys {
            switch c {
            case "<": if !composer.backspace() { out = String(out.dropLast()) }
            case " ": out += composer.commit() + " "
            default: out += composer.input(dubeolsik(c, shift: c.isUppercase)!)
            }
        }
        let got = out + "[" + composer.current.text + "]"
        if got != want {
            failed += 1
            print("FAIL \(keys): \(got), expected \(want)")
        }
    }
    print(failed == 0 ? "all \(cases.count) passed" : "\(failed) of \(cases.count) failed")
    return failed == 0
}
