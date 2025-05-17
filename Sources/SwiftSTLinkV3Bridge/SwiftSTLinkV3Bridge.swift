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

    // MARK: - I2C 相关桥接方法
    public func initI2CDevice(configuration: I2CConfiguration, 
                              addressMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, 
                              analogFilter: Brg_I2cFilterT = I2C_FILTER_DISABLE, 
                              digitalFilter: Brg_I2cFilterT = I2C_FILTER_DISABLE, 
                              digitalFilterConfig: UInt8 = 0) {
        guard let bridge else {
            return
        }

        var timingReg: UInt32 = 0   
        var status = bridge.pointee.GetI2cTiming(configuration.mode,
                                    Int32(configuration.speedFrequency), 
                                    Int32(configuration.noiseDigitalFilter), 
                                    Int32(configuration.riseTime), 
                                    Int32(configuration.fallTime), 
                                    configuration.analogFilter, 
                                    &timingReg)
        if status != BRG_NO_ERR {
            print("Error getting I2C timing: \(status)")
            return
        }

        var initParams = Brg_I2cInitT(
            TimingReg: timingReg,
            OwnAddr: 0,
            AddrMode: addressMode,
            AnFilterEn: analogFilter,
            DigitalFilterEn: digitalFilter,
            Dnf: digitalFilterConfig
        )

        status = bridge.pointee.InitI2C(&initParams)
        if status != BRG_NO_ERR {
            print("Error initializing I2C: \(status)")
            return
        }
    }

    /// 直接读取I2C设备数据（不写寄存器，适合流式/裸读）
    public func readI2C(addr: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadI2C(&buffer, addr, addrMode, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ReadI2C error: \(status)")
            return nil
        }
    }

    /// 先写寄存器地址再读数据（适合大多数I2C寄存器型设备，如MPU6050等）
    public func readI2CRegister(addr: UInt16, register: UInt8, length: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        buffer[0] = register
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadI2C(&buffer, addr, addrMode, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ReadI2C error: \(status)")
            return nil
        }
    }

    public func writeI2C(addr: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.WriteI2C(buf.baseAddress, addr, addrMode, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            return false
        }
    }

    public func startReadI2C(addr: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.StartReadI2C(&buffer, addr, addrMode, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("StartReadI2C error: \(status)")
            return nil
        }
    }

    public func contReadI2C(length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ContReadI2C(&buffer, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ContReadI2C error: \(status)")
            return nil
        }
    }

    public func stopReadI2C(length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.StopReadI2C(&buffer, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("StopReadI2C error: \(status)")
            return nil
        }
    }

    public func startWriteI2C(addr: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.StartWriteI2C(buf.baseAddress, addr, addrMode, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            return false
        }
    }

    public func contWriteI2C(data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.ContWriteI2C(buf.baseAddress, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            return false
        }
    }

    public func stopWriteI2C(data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.StopWriteI2C(buf.baseAddress, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            return false
        }
    }

    public func readNoWaitI2C(addr: UInt16, addrMode: Brg_I2cAddrModeT = I2C_ADDR_7BIT, length: UInt16, timeout: UInt16 = 0) -> (status: Int32, sizeRead: UInt16) {
        guard let bridge else { return (Int32(BRG_NO_STLINK.rawValue), 0) }
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadNoWaitI2C(addr, addrMode, length, &sizeRead, timeout)
        return (Int32(status.rawValue), sizeRead)
    }

    public func getReadDataI2C(length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        let status = bridge.pointee.GetReadDataI2C(&buffer, length)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(length)))
        } else {
            print("GetReadDataI2C error: \(status)")
            return nil
        }
    }
}