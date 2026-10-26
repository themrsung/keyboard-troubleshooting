// `KeyboardHealthCheck.app/Contents/MacOS/KeyboardHealthCheck --selftest`: the layout tables.

func selfTest() -> Bool {
    var failed = 0
    func check(_ ok: Bool, _ message: String) {
        if !ok { failed += 1; print("FAIL \(message)") }
    }
    for (board, count) in [(usBoard, 108), (isoBoard, 109), (jisBoard, 113)] {
        check(board.keys.count == count, "\(board.title): \(board.keys.count) keys, expected \(count)")
        check(Set(board.keys.map(\.usage)).count == board.keys.count, "\(board.title): a usage is on two keys")
        for key in board.keys {
            check(key.x >= 0 && key.x + key.w <= Board.width && key.y + key.h <= Board.height, "\(board.title): \(key.name) is off the board")
        }
        // No two keys overlap (the ISO Enter's footprint is checked as its bounding box, minus the notch).
        for (i, a) in board.keys.enumerated() {
            for b in board.keys[(i + 1)...] {
                let overlap = a.x < b.x + b.w - 0.01 && b.x < a.x + a.w - 0.01 && a.y < b.y + b.h - 0.01 && b.y < a.y + a.h - 0.01
                let notch = (a.isoEnter || b.isoEnter) && (a.isoEnter ? b : a).y == 3.5 && (a.isoEnter ? b : a).x + (a.isoEnter ? b : a).w <= 13.75
                check(!overlap || notch, "\(board.title): \(a.name) overlaps \(b.name)")
            }
        }
    }
    for (code, id) in usageForKeyCode {
        let (_, name) = describe(.key(id))
        check(name.hasPrefix("Key"), String(format: "key code 0x%02X: usage 0x%02X has no name", code, id))
    }
    print(failed == 0 ? "self-test passed" : "\(failed) checks failed")
    return failed == 0
}
