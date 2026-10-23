// viahid: read and write a VIA keyboard's keymap over raw HID, without the VIA web app.
//
//   swiftc -O -o viahid viahid.swift
//   ./viahid --vid 0x0416 --pid 0x8144 version
//   ./viahid --vid 0x0416 --pid 0x8144 --rows 7 --cols 16 read 0 > layer0.txt
//   ./viahid --vid 0x0416 --pid 0x8144 set 0 5 2 0091 1 5 1 0088
//
// version  VIA's protocol version (0x01), uptime (0x02/0x01), firmware version value (0x02/0x04),
//          and layer count (0x11). Add --vendor-version 0xF0 to also send a vendor's own version
//          command (0xF0 on Hansung) and print its first reply bytes.
// read L   Layer L as "row,col keycode" lines (DYNAMIC_KEYMAP_GET_BUFFER, 0x12). Read-only.
// set ...  Groups of "layer row col hexcode" (DYNAMIC_KEYMAP_SET_KEYCODE, 0x05). Writes to the
//          keyboard's keymap; back the layers up with `read` first.
//
// Talks to the interface VIA uses: usage page 0xFF60, usage 0x61, 32-byte reports, report ID 0.
// macOS asks for no permission for that vendor-defined interface.
import Foundation
import IOKit.hid

var args = Array(CommandLine.arguments.dropFirst())
func option(_ name: String, _ fallback: Int) -> Int {
    guard let i = args.firstIndex(of: name), i + 1 < args.count else { return fallback }
    let text = args[i + 1]
    args.removeSubrange(i...(i + 1))
    return text.hasPrefix("0x") ? Int(text.dropFirst(2), radix: 16)! : Int(text)!
}
let vid = option("--vid", -1), pid = option("--pid", -1)
let rows = option("--rows", 0), cols = option("--cols", 0)
let vendorVersion = option("--vendor-version", -1)
guard vid >= 0, pid >= 0, let command = args.first else {
    print("usage: viahid --vid 0xVVVV --pid 0xPPPP [--rows R --cols C] version|read L|set L R C CODE...")
    exit(64)
}

let manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
IOHIDManagerSetDeviceMatching(manager, [
    kIOHIDVendorIDKey: vid, kIOHIDProductIDKey: pid,
    kIOHIDPrimaryUsagePageKey: 0xFF60, kIOHIDPrimaryUsageKey: 0x61,
] as CFDictionary)
IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
IOHIDManagerOpen(manager, 0)
guard let device = (IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>)?.first else {
    print("no VIA raw HID interface for \(String(format: "%04X:%04X", vid, pid))")
    exit(1)
}

let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
var reply: [UInt8] = []
IOHIDDeviceRegisterInputReportCallback(device, buffer, 64, { _, _, _, _, _, report, length in
    reply = Array(UnsafeBufferPointer(start: report, count: length))
    CFRunLoopStop(CFRunLoopGetMain())
}, nil)

/// Sends one 32-byte report and waits up to 1.5 s for the answer.
func send(_ bytes: [UInt8]) -> [UInt8] {
    var report = [UInt8](repeating: 0, count: 32)
    for (i, b) in bytes.enumerated() where i < 32 { report[i] = b }
    reply = []
    IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, 0, report, report.count)
    CFRunLoopRunInMode(.defaultMode, 1.5, false)
    return reply
}
func hex(_ bytes: ArraySlice<UInt8>) -> String { bytes.map { String(format: "%02X", $0) }.joined(separator: " ") }

switch command {
case "version":
    let p = send([0x01])
    print("protocol version:", p.count > 2 ? Int(p[1]) << 8 | Int(p[2]) : -1)
    let up = send([0x02, 0x01])
    print("uptime (ms):", up.count > 5 ? up[2...5].reduce(0) { $0 << 8 | Int($1) } : -1)
    let fw = send([0x02, 0x04])
    print("firmware version value:", fw.count > 5 ? hex(fw[2...5]) : "none")
    let layers = send([0x11])
    print("layers:", layers.count > 1 ? Int(layers[1]) : -1)
    if vendorVersion >= 0 {
        let v = send([UInt8(vendorVersion)])
        print(String(format: "vendor command 0x%02X:", vendorVersion), hex(v.prefix(8)))
    }
case "read":
    guard rows > 0, cols > 0, args.count > 1, let layer = Int(args[1]) else { print("read needs --rows, --cols and a layer"); exit(64) }
    let total = rows * cols * 2
    var bytes: [UInt8] = []
    while bytes.count < total {
        let offset = layer * total + bytes.count, size = min(28, total - bytes.count)
        let r = send([0x12, UInt8(offset >> 8), UInt8(offset & 0xFF), UInt8(size)])
        guard r.count >= 4 + size, r[0] == 0x12 else { print("no answer at offset", offset); exit(2) }
        bytes += r[4..<(4 + size)]
    }
    for row in 0..<rows {
        for col in 0..<cols {
            let i = (row * cols + col) * 2
            print("\(row),\(col) \(String(format: "%04X", Int(bytes[i]) << 8 | Int(bytes[i + 1])))")
        }
    }
case "set":
    let values = Array(args.dropFirst())
    guard !values.isEmpty, values.count % 4 == 0 else { print("set takes groups of: layer row col hexcode"); exit(64) }
    for g in stride(from: 0, to: values.count, by: 4) {
        let code = UInt16(values[g + 3], radix: 16)!
        let r = send([0x05, UInt8(values[g])!, UInt8(values[g + 1])!, UInt8(values[g + 2])!,
                      UInt8(code >> 8), UInt8(code & 0xFF)])
        let ok = r.count >= 6 && r[0] == 0x05 && Int(r[4]) << 8 | Int(r[5]) == Int(code)
        print("L\(values[g]) \(values[g + 1]),\(values[g + 2]) = \(values[g + 3].uppercased()):", ok ? "ok" : "no echo (\(hex(r.prefix(6))))")
    }
default:
    print("unknown command:", command)
    exit(64)
}
