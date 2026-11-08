// naperaw: send raw HID reports to a Keychron Nape Pro's two vendor interfaces and print replies.
//
//   swiftc -O -o naperaw naperaw.swift
//   ./naperaw via 01                 # VIA interface (page 0xFF60): GET_PROTOCOL_VERSION
//   ./naperaw via a0                 # Keychron's own command on the VIA interface
//   ./naperaw kc 01 02               # page 0x8C interface: sends report 0xB2, waits for 0xB1
//   ./naperaw listen 10              # print whatever either interface sends for 10 s
//
// Bytes are hex. Each report is zero-padded to 32 bytes. The reply is the "<" line; reports the
// device sends on its own (such as `a3 layer angle dpi` after a setting changes) print as "~". The tool sends exactly what you give it,
// so a write command writes: check what a command does before sending it.
//
// Interfaces (USB, VID 0x3434 PID 0x0440, bcdDevice 0x0116):
//   via  usage page 0xFF60 usage 0x61, no report ID, 32-byte in/out (VIA raw HID)
//   kc   usage page 0x8C   usage 0x01, out report ID 0xB2, in report ID 0xB1, 32 bytes each
import Foundation
import IOKit.hid

var args = Array(CommandLine.arguments.dropFirst())
func option(_ name: String, _ fallback: Int) -> Int {
    guard let i = args.firstIndex(of: name), i + 1 < args.count else { return fallback }
    let text = args[i + 1]
    args.removeSubrange(i...(i + 1))
    return text.hasPrefix("0x") ? Int(text.dropFirst(2), radix: 16)! : Int(text)!
}
let vid = option("--vid", 0x3434), pid = option("--pid", 0x0440)
let timeout = Double(option("--timeout-ms", 1500)) / 1000
guard let command = args.first, ["via", "kc", "listen"].contains(command) else {
    print("usage: naperaw [--vid 0x3434 --pid 0x0440] [--timeout-ms 1500] via HEX...|kc HEX...|listen SECONDS")
    exit(64)
}

var managers: [IOHIDManager] = []  // a released manager closes its devices
func open(page: Int, usage: Int) -> IOHIDDevice? {
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
    IOHIDManagerSetDeviceMatching(manager, [
        kIOHIDVendorIDKey: vid, kIOHIDProductIDKey: pid,
        kIOHIDPrimaryUsagePageKey: page, kIOHIDPrimaryUsageKey: usage,
    ] as CFDictionary)
    IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDManagerOpen(manager, 0)
    managers.append(manager)
    return (IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>)?.first
}

func hex(_ bytes: [UInt8]) -> String { bytes.map { String(format: "%02x", $0) }.joined(separator: " ") }

var replies: [(String, [UInt8])] = []
func listen(_ device: IOHIDDevice, _ name: String) {
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
    let tag = Unmanaged.passRetained(name as NSString).toOpaque()
    IOHIDDeviceRegisterInputReportCallback(device, buffer, 64, { context, _, _, _, id, report, length in
        let name = Unmanaged<NSString>.fromOpaque(context!).takeUnretainedValue() as String
        var bytes = Array(UnsafeBufferPointer(start: report, count: length))
        if id != 0, bytes.first != UInt8(id) { bytes.insert(UInt8(id), at: 0) }
        // The device also pushes reports nobody asked for (e.g. `a3 layer angle dpi` after a change).
        // Those are kept and printed with "~"; only the matching reply ends the wait.
        let matches = expect.isEmpty || bytes.starts(with: expect)
        replies.append((matches ? name + " <" : name + " ~", bytes))
        if !listening && matches { CFRunLoopStop(CFRunLoopGetMain()) }
    }, tag)
}
var listening = false
var expect: [UInt8] = []  // prefix of the reply to wait for: the command byte, plus the subcommand for a7

let via = open(page: 0xFF60, usage: 0x61)
let kc = open(page: 0x8C, usage: 0x01)

switch command {
case "listen":
    listening = true
    if let via { listen(via, "via") } else { print("no VIA interface") }
    if let kc { listen(kc, "kc") } else { print("no 0x8C interface") }
    let seconds = Double(args.count > 1 ? args[1] : "10")!
    CFRunLoopRunInMode(.defaultMode, seconds, false)
    for (name, bytes) in replies { print("\(name) \(hex(bytes))") }
    if replies.isEmpty { print("nothing received in \(seconds) s") }
default:
    let payload = args.dropFirst().map { UInt8($0, radix: 16)! }
    guard let device = command == "via" ? via : kc else { print("no \(command) interface for \(String(format: "%04X:%04X", vid, pid))"); exit(1) }
    if command == "via" { expect = Array(payload.prefix(payload.first == 0xA7 ? 2 : 1)) }
    listen(device, command)
    var report = [UInt8](repeating: 0, count: 32)
    for (i, b) in payload.enumerated() where i < 32 { report[i] = b }
    let reportID = command == "via" ? 0 : 0xB2
    if reportID != 0 { report.insert(UInt8(reportID), at: 0) }
    let result = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, CFIndex(reportID), report, report.count)
    guard result == kIOReturnSuccess else { print("send failed: \(String(format: "0x%08x", result))"); exit(1) }
    print("\(command) > \(hex(report))")
    CFRunLoopRunInMode(.defaultMode, timeout, false)
    for (name, bytes) in replies { print("\(name) \(hex(bytes))") }
    if !replies.contains(where: { $0.0.hasSuffix("<") }) { print("no reply in \(timeout) s") }
}
