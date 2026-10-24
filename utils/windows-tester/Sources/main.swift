// windows-tester: shows each key and combination as Windows would receive it, and simulates the
// Microsoft IME Korean, while this window is focused. See README.md.

import AppKit

if CommandLine.arguments.contains("--selftest") { exit(selfTest() ? 0 : 1) }

final class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1180, height: 760),
                          styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
    let status = NSTextField(labelWithString: "")
    let typed = NSTextField(wrappingLabelWithString: "")
    let logView = NSTextView()
    lazy var simulator = Simulator { [weak self] in self?.append($0) }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let mono = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

        let type = NSPopUpButton()
        type.addItems(withTitles: KoreanType.allCases.map(\.label))
        type.target = self
        type.action = #selector(typeChanged(_:))
        type.refusesFirstResponder = true
        let clear = NSButton(title: "Clear", target: self, action: #selector(clear))
        clear.refusesFirstResponder = true

        status.font = mono
        typed.font = NSFont.systemFont(ofSize: 20)
        typed.isSelectable = false

        logView.isEditable = false
        logView.font = mono
        logView.isHorizontallyResizable = true
        logView.textContainer?.widthTracksTextView = false
        logView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let scroll = NSScrollView()
        scroll.documentView = logView
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = true

        let top = NSStackView(views: [type, clear])
        let stack = NSStackView(views: [top, status, typed, scroll])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        scroll.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -24).isActive = true
        typed.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -24).isActive = true
        window.contentView = stack
        window.title = "Windows tester (Microsoft IME Korean, simulated)"
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Every key goes to the simulator, never to AppKit, so no shortcut of this app fires.
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged, .systemDefined]) { [weak self] event in
            guard let self else { return event }
            switch event.type {
            case .keyDown: self.simulator.keyDown(keyCode: event.keyCode, isRepeat: event.isARepeat)
            case .keyUp: self.simulator.keyUp(keyCode: event.keyCode)
            case .flagsChanged:
                self.simulator.flagsChanged(keyCode: event.keyCode, flags: UInt64(event.modifierFlags.rawValue),
                                            capsLockOn: event.modifierFlags.contains(.capsLock))
            case .systemDefined where event.subtype.rawValue == 8:
                let code = (event.data1 & 0xFFFF0000) >> 16, state = (event.data1 & 0xFF00) >> 8
                self.simulator.media(code, down: state == 0xA)
                return event
            default: return event
            }
            self.refresh()
            return nil
        }
        append("Focus this window and type. ↓ key down, ↑ key up; indented lines are what follows in the app.")
        append("macOS takes some combinations before any app: ⌘Tab (Win+Tab), ⌘Space (Win+Space), Ctrl+arrows, and the input-source shortcuts.")
        refresh()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    @objc func typeChanged(_ sender: NSPopUpButton) {
        simulator.koreanType = KoreanType(rawValue: sender.indexOfSelectedItem)!
        append("— \(simulator.koreanType.label)")
    }

    @objc func clear() {
        simulator.clear()
        logView.string = ""
        refresh()
    }

    func refresh() {
        status.stringValue = simulator.status + "   Korean keyboard: \(simulator.koreanType.label.prefix(6))"
        let shown = NSMutableAttributedString(string: "Edit control: " + simulator.text.replacingOccurrences(of: "\n", with: "⏎\n"))
        let composing = simulator.composer.current.text
        if !composing.isEmpty {
            shown.append(NSAttributedString(string: composing, attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue, .backgroundColor: NSColor.selectedTextBackgroundColor,
            ]))
        }
        shown.append(NSAttributedString(string: "▏"))
        shown.addAttribute(.font, value: NSFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: shown.length))
        typed.attributedStringValue = shown
    }

    func append(_ line: String) {
        logView.textStorage?.append(NSAttributedString(string: line + "\n", attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular), .foregroundColor: NSColor.textColor,
        ]))
        logView.scrollToEndOfDocument(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
