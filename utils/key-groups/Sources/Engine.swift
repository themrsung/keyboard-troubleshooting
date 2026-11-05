// System-wide: an event tap that swallows member keys and sends each group's output. Needs
// Accessibility. Off unless the window's switch is on.
import ApplicationServices
import Foundation

let MARKER: Int64 = 0x4B47_5250   // tags the events we send, so the tap lets them through

final class Engine {
    static let shared = Engine()
    private(set) var groups: [Group] = []
    private var groupOf: [UInt16: Int] = [:]
    private var port: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let source = CGEventSource(stateID: .privateState)

    var running: Bool { port != nil }

    func configure(_ new: [Group]) {
        releaseAll()
        groups = new
        groupOf = [:]
        for (i, g) in new.enumerated() { for m in g.members { groupOf[m] = i } }
    }

    /// Starts the tap. False if macOS refuses it (no Accessibility).
    func start() -> Bool {
        if port != nil { return true }
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue) | CGEventMask(1 << CGEventType.keyUp.rawValue)
        guard let p = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
                                        eventsOfInterest: mask, callback: tapCallback, userInfo: nil) else { return false }
        port = p
        runLoopSource = CFMachPortCreateRunLoopSource(nil, p, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: p, enable: true)
        return true
    }

    func stop() {
        releaseAll()
        if let p = port { CGEvent.tapEnable(tap: p, enable: false); CFMachPortInvalidate(p) }
        if let s = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), s, .commonModes) }
        port = nil
        runLoopSource = nil
    }

    /// Lets go of every output still held, so nothing is left stuck down.
    func releaseAll() {
        for g in groups where g.active { send(g.output, down: false, flags: []) }
        groups = groups.map { Group(members: $0.members, output: $0.output, rule: $0.rule) }
    }

    func send(_ code: UInt16, down: Bool, flags: CGEventFlags, repeat isRepeat: Bool = false) {
        guard let e = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(code), keyDown: down) else { return }
        e.flags = flags
        e.setIntegerValueField(.eventSourceUserData, value: MARKER)
        if isRepeat { e.setIntegerValueField(.keyboardEventAutorepeat, value: 1) }
        e.post(tap: .cgSessionEventTap)
    }

    fileprivate func handle(_ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let p = port { CGEvent.tapEnable(tap: p, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        guard type == .keyDown || type == .keyUp,
              event.getIntegerValueField(.eventSourceUserData) != MARKER else { return Unmanaged.passUnretained(event) }
        let code = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        guard let gi = groupOf[code] else { return Unmanaged.passUnretained(event) }
        let down = type == .keyDown
        if down && event.getIntegerValueField(.keyboardEventAutorepeat) != 0 {
            // Sent keys don't repeat by themselves: repeat the output while a member repeats.
            if groups[gi].active { send(groups[gi].output, down: true, flags: event.flags, repeat: true) }
            return nil
        }
        switch groups[gi].handle(code, down: down) {
        case .down?: send(groups[gi].output, down: true, flags: event.flags)
        case .up?: send(groups[gi].output, down: false, flags: event.flags)
        case nil: break
        }
        return nil
    }
}

private let tapCallback: CGEventTapCallBack = { _, type, event, _ in
    Engine.shared.handle(type, event)
}
