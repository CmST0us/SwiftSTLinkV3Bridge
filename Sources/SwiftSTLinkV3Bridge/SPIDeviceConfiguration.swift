import CSTLinkV3Bridge
import Cxx
import CxxStdlib

public enum SPINssLevel {
    case low
    case high

    var value: Brg_SpiNssLevelT {
        switch self {
        case .low: return SPI_NSS_LOW
        case .high: return SPI_NSS_HIGH
        }
    }
}

public struct SPIDeviceConfiguration {
    public var direction: SPIDirection
    public var mode: SPIMode
    public var dataSize: SPIDataSize
    public var cpol: SPICPOL
    public var cpha: SPICPHA
    public var firstBit: SPIFirstBit
    public var frameFormat: SPIFrameFormat
    public var nss: SPINss
    public var nssPulse: SPINssPulse
    public var baudrate: SPIBaudratePrescaler
    public var crc: SPICrc
    public var crcPoly: UInt16
    public var spiDelay: SPIDelay

    public init(
        direction: SPIDirection = .fullDuplex,
        mode: SPIMode = .master,
        dataSize: SPIDataSize = .bits8,
        cpol: SPICPOL = .low,
        cpha: SPICPHA = .firstEdge,
        firstBit: SPIFirstBit = .msb,
        frameFormat: SPIFrameFormat = .motorola,
        nss: SPINss = .hard,
        nssPulse: SPINssPulse = .noPulse,
        baudrate: SPIBaudratePrescaler = .div8,
        crc: SPICrc = .disable,
        crcPoly: UInt16 = 0,
        spiDelay: SPIDelay = .noDelay
    ) {
        self.direction = direction
        self.mode = mode
        self.dataSize = dataSize
        self.cpol = cpol
        self.cpha = cpha
        self.firstBit = firstBit
        self.frameFormat = frameFormat
        self.nss = nss
        self.nssPulse = nssPulse
        self.baudrate = baudrate
        self.crc = crc
        self.crcPoly = crcPoly
        self.spiDelay = spiDelay
    }
}

// 常用 SPI 配置预设
public extension SPIDeviceConfiguration {
    static let `default` = fullDuplexMaster8b

    /// 标准全双工主机 8位 MSB，CPOL=0, CPHA=0
    static let fullDuplexMaster8b = SPIDeviceConfiguration()

    /// 标准全双工主机 16位 MSB，CPOL=0, CPHA=0
    static let fullDuplexMaster16b = SPIDeviceConfiguration(
        dataSize: .bits16
    )

    /// 半双工主机（只收）8位
    static let halfDuplexRxOnly = SPIDeviceConfiguration(
        direction: .rxOnly
    )

    /// 半双工主机（只发）8位
    static let halfDuplexTxOnly = SPIDeviceConfiguration(
        direction: .oneLineTx
    )

    /// CPOL=1, CPHA=1, 适配部分外设
    static let cpol1cpha1 = SPIDeviceConfiguration(
        cpol: .high,
        cpha: .secondEdge
    )

    /// LSB优先
    static let lsbFirst = SPIDeviceConfiguration(
        firstBit: .lsb
    )
}

// MARK: - Swift 友好型 SPI 枚举

public enum SPIDirection: UInt8 {
    case fullDuplex = 0
    case rxOnly = 1
    case oneLineRx = 2
    case oneLineTx = 3
    
    public var cValue: Brg_SpiDirT {
        switch self {
        case .fullDuplex: return SPI_DIRECTION_2LINES_FULLDUPLEX
        case .rxOnly: return SPI_DIRECTION_2LINES_RXONLY
        case .oneLineRx: return SPI_DIRECTION_1LINE_RX
        case .oneLineTx: return SPI_DIRECTION_1LINE_TX
        }
    }
}

public enum SPIMode: UInt8 {
    case slave = 0
    case master = 1
    public var cValue: Brg_SpiModeT {
        switch self {
        case .slave: return SPI_MODE_SLAVE
        case .master: return SPI_MODE_MASTER
        }
    }
}

public enum SPIDataSize: UInt8 {
    case bits16 = 0
    case bits8 = 1
    public var cValue: Brg_SpiDataSizeT {
        switch self {
        case .bits16: return SPI_DATASIZE_16B
        case .bits8: return SPI_DATASIZE_8B
        }
    }
}

public enum SPICPOL: UInt8 {
    case low = 0
    case high = 1
    public var cValue: Brg_SpiCpolT {
        switch self {
        case .low: return SPI_CPOL_LOW
        case .high: return SPI_CPOL_HIGH
        }
    }
}

public enum SPICPHA: UInt8 {
    case firstEdge = 0
    case secondEdge = 1
    public var cValue: Brg_SpiCphaT {
        switch self {
        case .firstEdge: return SPI_CPHA_1EDGE
        case .secondEdge: return SPI_CPHA_2EDGE
        }
    }
}

public enum SPIFirstBit: UInt8 {
    case lsb = 0
    case msb = 1
    public var cValue: Brg_SpiFirstBitT {
        switch self {
        case .lsb: return SPI_FIRSTBIT_LSB
        case .msb: return SPI_FIRSTBIT_MSB
        }
    }
}

public enum SPIFrameFormat: UInt8 {
    case motorola = 0
    case ti = 1
    public var cValue: Brg_SpiFrfT {
        switch self {
        case .motorola: return SPI_FRF_MOTOROLA
        case .ti: return SPI_FRF_TI
        }
    }
}

public enum SPINss: UInt8 {
    case soft = 0
    case hard = 1
    public var cValue: Brg_SpiNssT {
        switch self {
        case .soft: return SPI_NSS_SOFT
        case .hard: return SPI_NSS_HARD
        }
    }
}

public enum SPINssPulse: UInt8 {
    case noPulse = 0
    case pulse = 1
    public var cValue: Brg_SpiNssPulseT {
        switch self {
        case .noPulse: return SPI_NSS_NO_PULSE
        case .pulse: return SPI_NSS_PULSE
        }
    }
}

public enum SPIBaudratePrescaler: UInt8 {
    case div2 = 0
    case div4 = 1
    case div8 = 2
    case div16 = 3
    case div32 = 4
    case div64 = 5
    case div128 = 6
    case div256 = 7
    public var cValue: Brg_SpiBaudrateT {
        switch self {
        case .div2: return SPI_BAUDRATEPRESCALER_2
        case .div4: return SPI_BAUDRATEPRESCALER_4
        case .div8: return SPI_BAUDRATEPRESCALER_8
        case .div16: return SPI_BAUDRATEPRESCALER_16
        case .div32: return SPI_BAUDRATEPRESCALER_32
        case .div64: return SPI_BAUDRATEPRESCALER_64
        case .div128: return SPI_BAUDRATEPRESCALER_128
        case .div256: return SPI_BAUDRATEPRESCALER_256
        }
    }
}

public enum SPICrc: UInt8 {
    case disable = 0
    case enable = 1
    public var cValue: Brg_SpiCrcT {
        switch self {
        case .disable: return SPI_CRC_DISABLE
        case .enable: return SPI_CRC_ENABLE
        }
    }
}

public enum SPIDelay: UInt8 {
    case noDelay = 0
    case fewMicroSec = 1
    public var cValue: Brg_DelayT {
        switch self {
        case .noDelay: return DEFAULT_NO_DELAY
        case .fewMicroSec: return DELAY_FEW_MICROSEC
        }
    }
}

// MARK: - SPI 枚举 C -> Swift 转换

public extension SPIDirection {
    init(cValue: Brg_SpiDirT) {
        switch cValue {
        case SPI_DIRECTION_2LINES_FULLDUPLEX: self = .fullDuplex
        case SPI_DIRECTION_2LINES_RXONLY: self = .rxOnly
        case SPI_DIRECTION_1LINE_RX: self = .oneLineRx
        case SPI_DIRECTION_1LINE_TX: self = .oneLineTx
        default: self = .fullDuplex
        }
    }
}

public extension SPIMode {
    init(cValue: Brg_SpiModeT) {
        switch cValue {
        case SPI_MODE_SLAVE: self = .slave
        case SPI_MODE_MASTER: self = .master
        default: self = .master
        }
    }
}

public extension SPIDataSize {
    init(cValue: Brg_SpiDataSizeT) {
        switch cValue {
        case SPI_DATASIZE_16B: self = .bits16
        case SPI_DATASIZE_8B: self = .bits8
        default: self = .bits8
        }
    }
}

public extension SPICPOL {
    init(cValue: Brg_SpiCpolT) {
        switch cValue {
        case SPI_CPOL_LOW: self = .low
        case SPI_CPOL_HIGH: self = .high
        default: self = .low
        }
    }
}

public extension SPICPHA {
    init(cValue: Brg_SpiCphaT) {
        switch cValue {
        case SPI_CPHA_1EDGE: self = .firstEdge
        case SPI_CPHA_2EDGE: self = .secondEdge
        default: self = .firstEdge
        }
    }
}

public extension SPIFirstBit {
    init(cValue: Brg_SpiFirstBitT) {
        switch cValue {
        case SPI_FIRSTBIT_LSB: self = .lsb
        case SPI_FIRSTBIT_MSB: self = .msb
        default: self = .msb
        }
    }
}

public extension SPIFrameFormat {
    init(cValue: Brg_SpiFrfT) {
        switch cValue {
        case SPI_FRF_MOTOROLA: self = .motorola
        case SPI_FRF_TI: self = .ti
        default: self = .motorola
        }
    }
}

public extension SPINss {
    init(cValue: Brg_SpiNssT) {
        switch cValue {
        case SPI_NSS_SOFT: self = .soft
        case SPI_NSS_HARD: self = .hard
        default: self = .hard
        }
    }
}

public extension SPINssPulse {
    init(cValue: Brg_SpiNssPulseT) {
        switch cValue {
        case SPI_NSS_NO_PULSE: self = .noPulse
        case SPI_NSS_PULSE: self = .pulse
        default: self = .noPulse
        }
    }
}

public extension SPIBaudratePrescaler {
    init(cValue: Brg_SpiBaudrateT) {
        switch cValue {
        case SPI_BAUDRATEPRESCALER_2: self = .div2
        case SPI_BAUDRATEPRESCALER_4: self = .div4
        case SPI_BAUDRATEPRESCALER_8: self = .div8
        case SPI_BAUDRATEPRESCALER_16: self = .div16
        case SPI_BAUDRATEPRESCALER_32: self = .div32
        case SPI_BAUDRATEPRESCALER_64: self = .div64
        case SPI_BAUDRATEPRESCALER_128: self = .div128
        case SPI_BAUDRATEPRESCALER_256: self = .div256
        default: self = .div8
        }
    }
}

public extension SPICrc {
    init(cValue: Brg_SpiCrcT) {
        switch cValue {
        case SPI_CRC_DISABLE: self = .disable
        case SPI_CRC_ENABLE: self = .enable
        default: self = .disable
        }
    }
}

public extension SPIDelay {
    init(cValue: Brg_DelayT) {
        switch cValue {
        case DEFAULT_NO_DELAY: self = .noDelay
        case DELAY_FEW_MICROSEC: self = .fewMicroSec
        default: self = .noDelay
        }
    }
}

// MARK: - SPIDeviceConfiguration C -> Swift 转换

public extension SPIDeviceConfiguration {
    init(cStruct: Brg_SpiInitT) {
        self.direction = SPIDirection(cValue: cStruct.Direction)
        self.mode = SPIMode(cValue: cStruct.Mode)
        self.dataSize = SPIDataSize(cValue: cStruct.DataSize)
        self.cpol = SPICPOL(cValue: cStruct.Cpol)
        self.cpha = SPICPHA(cValue: cStruct.Cpha)
        self.firstBit = SPIFirstBit(cValue: cStruct.FirstBit)
        self.frameFormat = SPIFrameFormat(cValue: cStruct.FrameFormat)
        self.nss = SPINss(cValue: cStruct.Nss)
        self.nssPulse = SPINssPulse(cValue: cStruct.NssPulse)
        self.baudrate = SPIBaudratePrescaler(cValue: cStruct.Baudrate)
        self.crc = SPICrc(cValue: cStruct.Crc)
        self.crcPoly = cStruct.CrcPoly
        self.spiDelay = SPIDelay(cValue: cStruct.SpiDelay)
    }
} 