// The window's state: the saved groups, recording keys into them, the in-window test, and the
// system-wide switch.
import AppKit
import ApplicationServices

enum RecordTarget: Equatable { case members(UUID), output(UUID) }

final class Model: ObservableObject {
    @Published var groups: [GroupConfig] = [] {
        didSet { if groups != oldValue { save(); apply() } }
    }
    @Published private(set) var systemWide = false
    @Published private(set) var trusted = AXIsProcessTrusted()
    @Published private(set) var recording: RecordTarget?
    @Published private(set) var log: [String] = []
    @Published private(set) var heldOutputs: Set<UUID> = []   // in-window test: groups whose output is down
    @Published var message: String?

    private var testGroups: [UUID: Group] = [:]
    private var monitor: Any?
    private var timer: Timer?
    private let defaultsKey = "groups"

    init() {
        if let d = UserDefaults.standard.data(forKey: defaultsKey),
           let saved = try? JSONDecoder().decode([GroupConfig].self, from: d) { groups = saved }
        if groups.isEmpty { groups = [GroupConfig()] }
        apply()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] e in
            self?.local(e) ?? e
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            let now = AXIsProcessTrusted()
            if self?.trusted != now { self?.trusted = now }
        }
    }

    func problem(for id: UUID) -> String? {
        guard let i = groups.firstIndex(where: { $0.id == id }) else { return nil }
        return groups[i].problem(earlier: Array(groups[..<i]))
    }

    private func save() {
        if let d = try? JSONEncoder().encode(groups) { UserDefaults.standard.set(d, forKey: defaultsKey) }
    }

    /// The usable groups go to the system-wide engine and to the in-window test.
    private func apply() {
        let usable = groups.indices.filter { groups[$0].problem(earlier: Array(groups[..<$0])) == nil }.map { groups[$0] }
        Engine.shared.configure(usable.compactMap(\.group))
        testGroups = Dictionary(uniqueKeysWithValues: usable.compactMap { c in c.group.map { (c.id, $0) } })
        heldOutputs = []
    }

    // MARK: System-wide

    func setSystemWide(_ on: Bool) {
        if !on {
            Engine.shared.stop()
            systemWide = false
            return
        }
        guard AXIsProcessTrusted() else {
            message = "Allow Key Groups in Accessibility first."
            systemWide = false
            return
        }
        apply()
        if Engine.shared.start() {
            systemWide = true
            message = nil
        } else {
            message = "macOS refused the key tap. Check that Key Groups is allowed in Accessibility, then try again."
            systemWide = false
        }
    }

    func requestTrust() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: Recording keys

    /// Starts recording into a group (or stops, if it's already recording there). The system-wide
    /// tap pauses meanwhile, so the keys reach this window.
    func toggleRecording(_ target: RecordTarget) {
        if recording == target { finishRecording(); return }
        recording = target
        if Engine.shared.running { Engine.shared.stop() }
        if case .members(let id) = target, let i = groups.firstIndex(where: { $0.id == id }) { groups[i].members = [] }
    }

    func finishRecording() {
        recording = nil
        if systemWide && !Engine.shared.start() { systemWide = false }
    }

    func clearLog() { log = [] }

    // MARK: Keys in this window

    private func local(_ e: NSEvent) -> NSEvent? {
        let code = e.keyCode
        if let target = recording {
            if e.type == .keyDown && !e.isARepeat {
                switch target {
                case .members(let id):
                    if let i = groups.firstIndex(where: { $0.id == id }), !groups[i].members.contains(code) {
                        groups[i].members.append(code)
                    }
                case .output(let id):
                    if let i = groups.firstIndex(where: { $0.id == id }) { groups[i].output = code }
                    finishRecording()
                }
            }
            return nil
        }
        // System-wide on: the tap has already handled the members.
        guard !systemWide, let id = testGroups.first(where: { $0.value.members.contains(code) })?.key else { return e }
        if e.isARepeat { return nil }
        let down = e.type == .keyDown
        var g = testGroups[id]!
        let change = g.handle(code, down: down)
        testGroups[id] = g
        var line = "\(keyName(code)) \(down ? "↓" : "↑")"
        if let change {
            line += "    → \(keyName(g.output)) \(change == .down ? "↓" : "↑")"
            if change == .down { heldOutputs.insert(id) } else { heldOutputs.remove(id) }
        }
        log.append(line)
        if log.count > 300 { log.removeFirst(log.count - 300) }
        return nil
    }
}
