// The Swift Programming Language
// https://docs.swift.org/swift-book

import CSTLinkV3Bridge
import Cxx
import CxxStdlib

public class Bridge {
    private var interface: STLinkInterface

    private var deviceInfo: STLink_DeviceInfo2T?

    private var bridge: UnsafeMutablePointer<Brg>?

    public init() {
        self.interface = STLinkInterface(STLINK_BRIDGE)
        
        self.interface.LoadStlinkLibrary("")
    }

    public func enumDevices() {
        var deviceCount: UInt32 = 0
        interface.EnumDevices(&deviceCount, false)

        for i in 0..<deviceCount {
            var deviceInfo: STLink_DeviceInfo2T = STLink_DeviceInfo2T()
            interface.GetDeviceInfo2(Int32(i), &deviceInfo, UInt32(MemoryLayout<STLink_DeviceInfo2T>.size))
            if deviceInfo.DeviceUsed == 0 {
                self.deviceInfo = deviceInfo
                break
            }
        }
    }

    public func openDevice() {
        guard let deviceInfo else {
            return
        }

        let ptr = UnsafeMutablePointer<Brg>.allocate(capacity: 1)
        ptr.initialize(repeating: Brg(&interface), count: 1)
        self.bridge = ptr

        bridge?.pointee.SetOpenModeExclusive(true)
        var serialNumber = deviceInfo.EnumUniqueId
        
        withUnsafePointer(to: &serialNumber) { pointer in
            let bound = pointer.withMemoryRebound(to: CChar.self, capacity: Int(SERIAL_NUM_STR_MAX_LEN)) {$0}
            bridge?.pointee.OpenStlink(bound, false)
        }
    }

    public func testDevice() {
        var gpioClockHz: UInt32 = 0
        var stlinkHClockKHz: UInt32 = 0
        bridge?.pointee.GetClk(UInt8(COM_GPIO), &gpioClockHz, &stlinkHClockKHz)
        print("gpioClockHz: \(gpioClockHz), stlinkHClock: \(stlinkHClockKHz)")
    }
}