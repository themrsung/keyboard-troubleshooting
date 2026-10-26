// Draws the three boards, scaled to fit, each key colored by its state: untested (gray), held down
// now (blue), registered at least once (green), possible chatter (orange).

import AppKit

enum KeyState { case tested, chatter }   // no entry: untested

final class KeyboardView: NSView {
    var states: [Usage: KeyState] = [:] { didSet { needsDisplay = true } }
    var held: Set<Usage> = [] { didSet { needsDisplay = true } }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        bounds.fill()
        let titleHeight = 0.6, gapHeight = 0.3   // in key units
        let perBoard = Board.height + titleHeight + gapHeight
        let unit = min((bounds.width - 24) / Board.width, (bounds.height - 12) / (perBoard * Double(boards.count)))
        let originX = (bounds.width - Board.width * unit) / 2
        for (i, board) in boards.enumerated() {
            let top = 6 + Double(i) * perBoard * unit
            let tested = Set(board.keys.map(\.usage)).filter { states[$0] != nil }.count
            let title = "\(board.title) — \(tested) of \(board.keys.count) registered"
            title.draw(at: NSPoint(x: originX, y: top), withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: max(10, unit * 0.32)), .foregroundColor: NSColor.labelColor,
            ])
            for key in board.keys {
                draw(key, origin: NSPoint(x: originX, y: top + titleHeight * unit), unit: unit)
            }
        }
    }

    private func draw(_ key: Key, origin: NSPoint, unit: Double) {
        let inset = unit * 0.05, radius = unit * 0.1
        func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> NSRect {
            NSRect(x: origin.x + x * unit + inset, y: origin.y + y * unit + inset, width: w * unit - 2 * inset, height: h * unit - 2 * inset)
        }
        let path: NSBezierPath
        if key.isoEnter {
            // Top part 1.5u wide, bottom part the right 1.25u.
            path = NSBezierPath(roundedRect: rect(key.x, key.y, key.w, 1), xRadius: radius, yRadius: radius)
            path.append(NSBezierPath(roundedRect: rect(key.x + 0.25, key.y + 0.5, key.w - 0.25, 1.5), xRadius: radius, yRadius: radius))
        } else {
            path = NSBezierPath(roundedRect: rect(key.x, key.y, key.w, key.h), xRadius: radius, yRadius: radius)
        }
        let fill: NSColor
        if held.contains(key.usage) {
            fill = .systemBlue
        } else {
            switch states[key.usage] {
            case nil: fill = NSColor.quaternaryLabelColor
            case .tested: fill = NSColor.systemGreen.withAlphaComponent(0.75)
            case .chatter: fill = .systemOrange
            }
        }
        fill.setFill()
        path.fill()
        NSColor.separatorColor.setStroke()
        path.stroke()

        let font = NSFont.systemFont(ofSize: unit * (key.legend.count > 4 ? 0.22 : 0.3))
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.labelColor]
        let size = key.legend.size(withAttributes: attrs)
        let box = rect(key.x, key.y, key.w, key.isoEnter ? 1 : key.h)
        key.legend.draw(at: NSPoint(x: box.midX - size.width / 2, y: box.midY - size.height / 2), withAttributes: attrs)
    }
}
