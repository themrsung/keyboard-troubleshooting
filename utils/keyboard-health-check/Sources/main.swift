// keyboard-health-check: while this window is focused, logs every key down and up and lights the key
// on full-size US, ISO and JIS boards, so dead, chattering or stuck switches show. See README.md.

import AppKit
import IOKit
import UniformTypeIdentifiers

if CommandLine.arguments.contains("--selftest") { exit(selfTest() ? 0 : 1) }

/// A press closer than this to the same key's last release is flagged as possible chatter.
let chatterThreshold = 0.030

final class AppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1400, height: 1000),
                          styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
    let keyboard = KeyboardView()
    let logView = NSTextView()
    let devicePopup = NSPopUpButton()
    let status = NSTextField(labelWithString: "")
    let hid = HIDReader()
    var usingHID = false

    var presses: [Usage: Int] = [:]
    var lastUp: [Usage: Double] = [:]
    var downAt: [Usage: Double] = [:]
    var devices: [String] = []
    let clock: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let mono = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        func button(_ title: String, _ action: Selector) -> NSButton {
            let b = NSButton(title: title, target: self, action: action)
            b.refusesFirstResponder = true
            return b
        }
        devicePopup.addItem(withTitle: "All keyboards")
        devicePopup.target = self
        devicePopup.action = #selector(deviceChanged)
        devicePopup.refusesFirstResponder = true
        status.font = mono

        logView.isEditable = false
        logView.font = mono
        logView.backgroundColor = .textBackgroundColor
        let scroll = NSScrollView()
        scroll.documentView = logView
        scroll.hasVerticalScroller = true
        logView.autoresizingMask = [.width]
        logView.textContainer?.widthTracksTextView = true

        let top = NSStackView(views: [
            NSTextField(labelWithString: "Device:"), devicePopup,
            button("Reset keys", #selector(resetKeys)), button("CLEAR", #selector(clearLog)), button("EXPORT", #selector(exportLog)),
            status,
        ])
        let content = NSView()
        for view in [top, keyboard, scroll] as [NSView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(view)
        }
        top.setContentHuggingPriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: content.topAnchor, constant: 10),
            top.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            top.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -12),
            keyboard.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 8),
            keyboard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            keyboard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            keyboard.heightAnchor.constraint(equalTo: content.heightAnchor, multiplier: 0.68),
            scroll.topAnchor.constraint(equalTo: keyboard.bottomAnchor, constant: 8),
            scroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            scroll.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -12),
            scroll.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -12),
        ])
        window.contentView = content
        window.title = "Keyboard health check"
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        log("Keyboard health check started. Focus this window and press every key; each key down (↓) and up (↑) is logged.")
        log("Colors: gray untested · blue held · green registered · orange possible chatter (pressed again within \(Int(chatterThreshold * 1000)) ms of release).")
        startHID()

        // Keys never reach AppKit, so nothing types or triggers a shortcut here. In HID mode the key
        // events are only swallowed; the HID reader does the logging.
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged, .systemDefined]) { [weak self] event in
            guard let self else { return event }
            if event.type == .systemDefined {
                guard event.subtype.rawValue == 8 else { return event }
                if !self.usingHID {
                    let code = (event.data1 & 0xFFFF0000) >> 16, state = (event.data1 & 0xFF00) >> 8
                    if let id = usageForMediaKey[code] {
                        self.record(.consumer(id), down: state == 0xA, device: "(macOS key event)", time: event.timestamp)
                    }
                }
                return event
            }
            if !self.usingHID { self.fallback(event) }
            return nil
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.log("— focus lost: keys are not logged until this window is focused again")
            self.downAt.removeAll()
            self.keyboard.held = []
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.log("— focused: logging keys")
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    // MARK: Sources

    func startHID() {
        if !HIDReader.hasAccess { _ = HIDReader.requestAccess() }
        guard HIDReader.hasAccess else {
            log("Input Monitoring isn't allowed, so this reads macOS key events instead: no device names, and some keys")
            log("  arrive as others (Print Screen as F13, Insert as Help, Num Lock as Clear; 無変換 and 変換 never arrive).")
            log("  To read the keyboards themselves: System Settings → Privacy & Security → Input Monitoring → turn on")
            log("  Keyboard Health Check, then quit and reopen it.")
            status.stringValue = "Mode: macOS key events (no Input Monitoring)"
            return
        }
        hid.onDevice = { [weak self] name, added in
            guard let self else { return }
            self.log(added ? "+ device connected: \(name)" : "− device removed: \(name)")
            if added, !self.devices.contains(name) {
                self.devices.append(name)
                self.devicePopup.addItem(withTitle: name)
            }
        }
        hid.onEvent = { [weak self] e in
            guard let self, NSApp.isActive else { return }
            let selected = self.devicePopup.indexOfSelectedItem == 0 ? nil : self.devicePopup.titleOfSelectedItem
            guard selected == nil || selected == e.device else { return }
            self.record(e.usage, down: e.down, device: e.device, time: e.time)
        }
        hid.onRollover = { [weak self] device in
            guard NSApp.isActive else { return }
            self?.log("⚠ rollover error from \(device): too many keys at once, or a fault in the key matrix")
        }
        // Opening fails as a whole if any one device can't be opened (one another app holds exclusively,
        // such as a keyboard Karabiner-Elements modifies), but the other devices still report.
        let result = hid.start()
        usingHID = true
        status.stringValue = "Mode: HID (reading the keyboards directly)"
        log("Reading keyboards at the HID level (Input Monitoring allowed).")
        if result != kIOReturnSuccess {
            log(String(format: "⚠ Not every device could be opened (IOReturn 0x%08X); a keyboard another app holds", UInt32(bitPattern: result)))
            log("  exclusively, e.g. one Karabiner-Elements modifies, reports through that app's virtual keyboard instead.")
        }
    }

    func fallback(_ event: NSEvent) {
        guard let id = usageForKeyCode[event.keyCode] else {
            log(String(format: "? macOS key code 0x%02X (%@), no HID usage known", event.keyCode, event.type == .keyUp ? "up" : "down"))
            return
        }
        let usage = Usage.key(id)
        switch event.type {
        case .keyDown:
            if event.isARepeat { return }
            record(usage, down: true, device: "(macOS key event)", time: event.timestamp)
        case .keyUp:
            record(usage, down: false, device: "(macOS key event)", time: event.timestamp)
        case .flagsChanged:
            if event.keyCode == 0x39 {
                // Caps Lock reports only its toggle, so each change counts as one press.
                record(usage, down: true, device: "(macOS key event)", time: event.timestamp)
                record(usage, down: false, device: "(macOS key event)", time: event.timestamp)
            } else if let bit = modifierBit[event.keyCode] {
                record(usage, down: event.modifierFlags.rawValue & bit != 0, device: "(macOS key event)", time: event.timestamp)
            }
        default: break
        }
    }

    // MARK: State and log

    func record(_ usage: Usage, down: Bool, device: String, time: Double) {
        let (legend, name) = describe(usage)
        let label = "\(legend)  \(name)  \(usage.hex)"
        if down {
            if downAt[usage] != nil { log("⚠ \(label): down again without an up, from \(device)") }
            presses[usage, default: 0] += 1
            downAt[usage] = time
            var line = "↓ \(label)  press #\(presses[usage]!)  \(device)"
            if let up = lastUp[usage], time - up < chatterThreshold {
                line += String(format: "  ⚠ %.1f ms after its last release: chatter?", (time - up) * 1000)
                keyboard.states[usage] = .chatter
            } else if keyboard.states[usage] == nil {
                keyboard.states[usage] = .tested
            }
            log(line)
            keyboard.held.insert(usage)
        } else {
            let held = downAt[usage].map { String(format: "  held %.0f ms", (time - $0) * 1000) } ?? "  (no down seen)"
            log("↑ \(label)\(held)")
            downAt[usage] = nil
            lastUp[usage] = time
            keyboard.held.remove(usage)
        }
    }

    func log(_ line: String) {
        logView.textStorage?.append(NSAttributedString(string: clock.string(from: Date()) + "  " + line + "\n", attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: line.hasPrefix("⚠") || line.contains("⚠") ? NSColor.systemOrange : NSColor.textColor,
        ]))
        logView.scrollToEndOfDocument(nil)
    }

    // MARK: Buttons

    @objc func deviceChanged() {
        log("— showing: \(devicePopup.titleOfSelectedItem ?? "")")
    }

    @objc func resetKeys() {
        presses.removeAll()
        lastUp.removeAll()
        downAt.removeAll()
        keyboard.states = [:]
        keyboard.held = []
        log("— keys reset")
    }

    @objc func clearLog() {
        logView.string = ""
    }

    @objc func exportLog() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        let stamp = DateFormatter()
        stamp.dateFormat = "yyyyMMdd-HHmmss"
        panel.nameFieldStringValue = "keyboard-health-check-\(stamp.string(from: Date())).txt"
        panel.beginSheetModal(for: window) { [weak self] response in
            guard let self, response == .OK, let url = panel.url else { return }
            do {
                try self.logView.string.write(to: url, atomically: true, encoding: .utf8)
                self.log("— exported to \(url.path)")
            } catch {
                self.log("⚠ export failed: \(error.localizedDescription)")
            }
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
