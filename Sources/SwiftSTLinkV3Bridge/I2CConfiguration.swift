import CSTLinkV3Bridge
import Cxx
import CxxStdlib


public struct I2CConfiguration {
    public var mode: I2cModeT
    public var speedFrequency: Int32 // In KHz, 1-100KHz (STANDARD), 1-400KHz (FAST), 1-1000KHz (FAST PLUS)
    public var noiseDigitalFilter: Int32  //0 (no digital filter) up to 15, noise digital filter (delay = DNFn/SpeedFrequency)
    public var riseTime: Int32 // In ns, 0-1000ns (STANDARD), 0-300ns (FAST), 0-120ns (FAST PLUS)
    public var fallTime: Int32 // In ns, 0-300ns (STANDARD), 0-300ns (FAST), 0-120ns (FAST PLUS)
    public var analogFilter: Bool // Use true for Analog Filter ON or false for Analog Filter OFF

    public static var standard = {
        I2CConfiguration(mode: I2C_STANDARD, 
            speedFrequency: 100, 
            noiseDigitalFilter: 0, 
            riseTime: 0, 
            fallTime: 0, 
            analogFilter: false)
    }()

    public static var fast = { 
        I2CConfiguration(mode: I2C_FAST, 
            speedFrequency: 400, 
            noiseDigitalFilter: 0, 
            riseTime: 0, 
            fallTime: 0, 
            analogFilter: false)
    }()

    public static var fastPlus = { 
        I2CConfiguration(mode: I2C_FAST_PLUS, 
            speedFrequency: 1000, 
            noiseDigitalFilter: 0, 
            riseTime: 0, 
            fallTime: 0, 
            analogFilter: false)
    }()

    public init(mode: I2cModeT, speedFrequency: Int32, noiseDigitalFilter: Int32, riseTime: Int32, fallTime: Int32, analogFilter: Bool) {
        self.mode = mode
        self.speedFrequency = speedFrequency
        self.noiseDigitalFilter = noiseDigitalFilter
        self.riseTime = riseTime
        self.fallTime = fallTime
        self.analogFilter = analogFilter
    }
}

// MARK: - I2C 地址模式 Swift 枚举

public enum I2CAddressMode: UInt8 {
    case bit7 = 0
    case bit10 = 1

    public var cValue: Brg_I2cAddrModeT {
        switch self {
        case .bit7: return I2C_ADDR_7BIT
        case .bit10: return I2C_ADDR_10BIT
        }
    }

    public init(cValue: Brg_I2cAddrModeT) {
        switch cValue {
        case I2C_ADDR_7BIT: self = .bit7
        case I2C_ADDR_10BIT: self = .bit10
        default: self = .bit7
        }
    }
}


// MARK: - I2C 枚举 C -> Swift 转换

public enum I2CMode: Int32 {
    case standard = 0
    case fast = 1
    case fastPlus = 2
    public var cValue: I2cModeT {
        switch self {
        case .standard: return I2C_STANDARD
        case .fast: return I2C_FAST
        case .fastPlus: return I2C_FAST_PLUS
        }
    }
    public init(cValue: I2cModeT) {
        switch cValue {
        case I2C_STANDARD: self = .standard
        case I2C_FAST: self = .fast
        case I2C_FAST_PLUS: self = .fastPlus
        default: self = .standard
        }
    }
}

public extension I2CConfiguration {
    init(cStruct: Brg_I2cInitT) {
        self.mode = I2cModeT(cStruct.TimingReg) // 这里需根据实际映射调整
        self.speedFrequency = 0 // 需外部补充
        self.noiseDigitalFilter = 0 // 需外部补充
        self.riseTime = 0 // 需外部补充
        self.fallTime = 0 // 需外部补充
        self.analogFilter = cStruct.AnFilterEn == I2C_FILTER_ENABLE
    }
}

// MARK: - I2C 滤波器 Swift 枚举

public enum I2CFilter: UInt8 {
    case disable = 0
    case enable = 1
    
    public var cValue: Brg_I2cFilterT {
        switch self {
        case .disable: return I2C_FILTER_DISABLE
        case .enable: return I2C_FILTER_ENABLE
        }
    }
    
    public init(cValue: Brg_I2cFilterT) {
        switch cValue {
        case I2C_FILTER_DISABLE: self = .disable
        case I2C_FILTER_ENABLE: self = .enable
        default: self = .disable
        }
    }
}
