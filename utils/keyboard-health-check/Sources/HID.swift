// Reads keyboards at the HID level (IOHIDManager), so each press is reported with the device that
// sent it and as the usage the keyboard really sent: Print Screen stays Print Screen (not F13), and
// 無変換 / 変換 / カタカナ show up although macOS sends apps nothing for them. Needs Input Monitoring.
// Nothing is seized: the keys still reach macOS as usual.

import Foundation
import IOKit.hid

struct HIDEvent {
    let usage: Usage
    let down: Bool
    let device: String
    let time: Double   // seconds, from the HID timestamp
}

final class HIDReader {
    private let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    private var timebase = mach_timebase_info_data_t()
    var onEvent: (HIDEvent) -> Void = { _ in }
    var onRollover: (String) -> Void = { _ in }
    var onDevice: (String, Bool) -> Void = { _, _ in }

    static var hasAccess: Bool { IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted }
    /// Asks macOS for Input Monitoring; the first time, it shows the system prompt.
    static func requestAccess() -> Bool { IOHIDRequestAccess(kIOHIDRequestTypeListenEvent) }

    /// Starts reading; the result is IOHIDManagerOpen's.
    func start() -> IOReturn {
        mach_timebase_info(&timebase)
        let matches: [[String: Int]] = [
            [kIOHIDDeviceUsagePageKey: 0x01, kIOHIDDeviceUsageKey: 0x06],   // keyboards
            [kIOHIDDeviceUsagePageKey: 0x0C, kIOHIDDeviceUsageKey: 0x01],   // consumer controls (media keys)
        ]
        IOHIDManagerSetDeviceMatchingMultiple(manager, matches as CFArray)
        let me = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { ctx, _, _, device in
            let reader = Unmanaged<HIDReader>.fromOpaque(ctx!).takeUnretainedValue()
            reader.onDevice(HIDReader.name(of: device), true)
        }, me)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { ctx, _, _, device in
            let reader = Unmanaged<HIDReader>.fromOpaque(ctx!).takeUnretainedValue()
            reader.onDevice(HIDReader.name(of: device), false)
        }, me)
        IOHIDManagerRegisterInputValueCallback(manager, { ctx, _, _, value in
            Unmanaged<HIDReader>.fromOpaque(ctx!).takeUnretainedValue().handle(value)
        }, me)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        return IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    static func name(of device: IOHIDDevice) -> String {
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String
        let vendor = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
        let productID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
        let trimmed = product?.trimmingCharacters(in: .whitespaces) ?? ""
        return String(format: "%@ (%04X:%04X)", trimmed.isEmpty ? "unnamed" : trimmed, vendor, productID)
    }

    private func handle(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let page = IOHIDElementGetUsagePage(element), id = IOHIDElementGetUsage(element)
        let device = HIDReader.name(of: IOHIDElementGetDevice(element))
        // Array elements report usage 0xFFFFFFFF or 0; only real key usages are kept.
        if page == 0x07 {
            if id == 0x01 || id == 0x02 || id == 0x03 {
                // ErrorRollOver / POSTFail / ErrorUndefined: too many keys at once, or a matrix fault.
                if IOHIDValueGetIntegerValue(value) != 0 { onRollover(device) }
                return
            }
            guard (0x04...0xE7).contains(id) else { return }
        } else if page == 0x0C {
            guard id != 0 && id != 0xFFFFFFFF && id != 0x01 else { return }
        } else {
            return
        }
        let ticks = IOHIDValueGetTimeStamp(value)
        let seconds = Double(ticks) * Double(timebase.numer) / Double(timebase.denom) / 1e9
        onEvent(HIDEvent(usage: Usage(page: page, id: id), down: IOHIDValueGetIntegerValue(value) != 0,
                         device: device, time: seconds))
    }
}
