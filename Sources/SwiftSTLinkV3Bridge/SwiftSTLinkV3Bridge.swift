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
                              addressMode: I2CAddressMode = .bit7, 
                              analogFilter: I2CFilter = .disable, 
                              digitalFilter: I2CFilter = .disable, 
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
            AddrMode: addressMode.cValue,
            AnFilterEn: analogFilter.cValue,
            DigitalFilterEn: digitalFilter.cValue,
            Dnf: digitalFilterConfig
        )

        status = bridge.pointee.InitI2C(&initParams)
        if status != BRG_NO_ERR {
            print("Error initializing I2C: \(status)")
            return
        }
    }

    /// 直接读取I2C设备数据（不写寄存器，适合流式/裸读）
    public func readI2C(addr: UInt16, addrMode: I2CAddressMode = .bit7, length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadI2C(&buffer, addr, addrMode.cValue, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ReadI2C error: \(status)")
            return nil
        }
    }

    /// 先写寄存器地址再读数据（适合大多数I2C寄存器型设备，如MPU6050等）
    public func readI2CRegister(addr: UInt16, register: UInt8, length: UInt16, addrMode: I2CAddressMode = .bit7) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        buffer[0] = register
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadI2C(&buffer, addr, addrMode.cValue, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ReadI2C error: \(status)")
            return nil
        }
    }

    public func writeI2C(addr: UInt16, addrMode: I2CAddressMode = .bit7, data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.WriteI2C(buf.baseAddress, addr, addrMode.cValue, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            return false
        }
    }

    public func startReadI2C(addr: UInt16, addrMode: I2CAddressMode = .bit7, length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.StartReadI2C(&buffer, addr, addrMode.cValue, length, &sizeRead)
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

    public func startWriteI2C(addr: UInt16, addrMode: I2CAddressMode = .bit7, data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.StartWriteI2C(buf.baseAddress, addr, addrMode.cValue, UInt16(data.count), &sizeWritten)
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

    public func readNoWaitI2C(addr: UInt16, addrMode: I2CAddressMode = .bit7, length: UInt16, timeout: UInt16 = 0) -> (status: Int32, sizeRead: UInt16) {
        guard let bridge else { return (Int32(BRG_NO_STLINK.rawValue), 0) }
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadNoWaitI2C(addr, addrMode.cValue, length, &sizeRead, timeout)
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

    // MARK: - SPI 相关桥接方法
    /// SPI 初始化
    public func initSPI(configuration: SPIDeviceConfiguration) {
        guard let bridge else { return }
        var initParams = Brg_SpiInitT(
            Direction: configuration.direction.cValue,
            Mode: configuration.mode.cValue,
            DataSize: configuration.dataSize.cValue,
            Cpol: configuration.cpol.cValue,
            Cpha: configuration.cpha.cValue,
            FirstBit: configuration.firstBit.cValue,
            FrameFormat: configuration.frameFormat.cValue,
            Nss: configuration.nss.cValue,
            NssPulse: configuration.nssPulse.cValue,
            Baudrate: configuration.baudrate.cValue,
            Crc: configuration.crc.cValue,
            CrcPoly: configuration.crcPoly,
            SpiDelay: configuration.spiDelay.cValue
        )
        let status = bridge.pointee.InitSPI(&initParams)
        if status != BRG_NO_ERR {
            print("InitSPI error: \(status)")
        }
    }

    /// 获取 SPI 波特率分频参数
    public func getSPIBaudratePrescaler(reqFreqKHz: UInt32) -> (baudrate: SPIBaudratePrescaler, finalFreqKHz: UInt32, status: Int32) {
        guard let bridge else { return (SPIBaudratePrescaler(cValue: SPI_BAUDRATEPRESCALER_2), 0, Int32(BRG_NO_STLINK.rawValue)) }
        var baudrate = SPI_BAUDRATEPRESCALER_2
        var finalFreq: UInt32 = 0
        let status = bridge.pointee.GetSPIbaudratePrescal(reqFreqKHz, &baudrate, &finalFreq)
        return (SPIBaudratePrescaler(cValue: baudrate), finalFreq, Int32(status.rawValue))
    }

    /// SPI 片选（NSS）引脚控制（仅软控模式有效）
    public func setSPINss(level: SPINssLevel) -> Bool {
        guard let bridge else { return false }
        let status = bridge.pointee.SetSPIpinCS(level.value)
        return status == BRG_NO_ERR
    }

    /// SPI 写数据
    public func writeSPI(data: [UInt8]) -> Bool {
        guard let bridge else { return false }
        var sizeWritten: UInt16 = 0
        let status = data.withUnsafeBufferPointer { buf in
            bridge.pointee.WriteSPI(buf.baseAddress, UInt16(data.count), &sizeWritten)
        }
        if status == BRG_NO_ERR {
            return true
        } else {
            print("WriteSPI error: \(status)")
            return false
        }
    }

    /// SPI 读数据
    public func readSPI(length: UInt16) -> [UInt8]? {
        guard let bridge else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(length))
        var sizeRead: UInt16 = 0
        let status = bridge.pointee.ReadSPI(&buffer, length, &sizeRead)
        if status == BRG_NO_ERR {
            return Array(buffer.prefix(Int(sizeRead)))
        } else {
            print("ReadSPI error: \(status)")
            return nil
        }
    }

    // MARK: - GPIO 相关桥接方法
    /// GPIO 初始化
    public func initGPIO(mask: GPIOMask, config: [GPIOConfiguration]) -> Bool {
        guard let bridge else { return false }
        var conf = config.map { $0.cStruct }
        return conf.withUnsafeMutableBufferPointer { buf in
            var initParams = Brg_GpioInitT(
                GpioMask: mask.rawValue,
                ConfigNb: UInt8(config.count),
                pGpioConf: buf.baseAddress
            )
            let status = bridge.pointee.InitGPIO(&initParams)
            if status != BRG_NO_ERR {
                print("InitGPIO error: \(status)")
                return false
            }
            return true
        }
    }

    /// 读取 GPIO 状态
    public func readGPIO(mask: GPIOMask) -> [GPIOValue]? {
        guard let bridge else { return nil }
        var values = [Brg_GpioValT](repeating: GPIO_RESET, count: 4)
        var errorMask: UInt8 = 0
        let status = bridge.pointee.ReadGPIO(mask.rawValue, &values, &errorMask)
        if status == BRG_NO_ERR && errorMask == 0 {
            return values.map { GPIOValue(cValue: $0) }
        } else {
            print("ReadGPIO error: \(status), errorMask: \(errorMask)")
            return nil
        }
    }

    /// 设置/复位 GPIO
    public func setResetGPIO(mask: GPIOMask, values: [GPIOValue]) -> Bool {
        guard let bridge else { return false }
        var vals = values.map { $0.cValue }
        var errorMask: UInt8 = 0
        let status = bridge.pointee.SetResetGPIO(mask.rawValue, &vals, &errorMask)
        if status == BRG_NO_ERR && errorMask == 0 {
            return true
        } else {
            print("SetResetGPIO error: \(status), errorMask: \(errorMask)")
            return false
        }
    }
}