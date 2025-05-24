import CSTLinkV3Bridge
import Cxx
import CxxStdlib

public struct GPIOConfiguration {
    public var mode: GPIOMode
    public var speed: GPIOSpeed
    public var pull: GPIOPull
    public var outputType: GPIOOutputType

    public init(
        mode: GPIOMode = .output,
        speed: GPIOSpeed = .high,
        pull: GPIOPull = .none,
        outputType: GPIOOutputType = .pushPull
    ) {
        self.mode = mode
        self.speed = speed
        self.pull = pull
        self.outputType = outputType
    }

    /// 转为 C 层 Brg_GpioConfT
    public var cStruct: Brg_GpioConfT {
        Brg_GpioConfT(
            Mode: mode.cValue,
            Speed: speed.cValue,
            Pull: pull.cValue,
            OutputType: outputType.cValue
        )
    }
}

// 常用 GPIO 配置预设
public extension GPIOConfiguration {
    /// 推挽输出，高速，无上下拉
    static let pushPullOutput = GPIOConfiguration()

    /// 开漏输出，高速，无上下拉
    static let openDrainOutput = GPIOConfiguration(outputType: .openDrain)

    /// 输入，无上下拉
    static let input = GPIOConfiguration(mode: .input)

    /// 输入，上拉
    static let inputPullUp = GPIOConfiguration(mode: .input, pull: .up)

    /// 输入，下拉
    static let inputPullDown = GPIOConfiguration(mode: .input, pull: .down)

    /// 模拟输入
    static let analog = GPIOConfiguration(mode: .analog)
}

// MARK: - GPIO 掩码 Swift OptionSet

public struct GPIOMask: OptionSet {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    // 单个 GPIO 引脚
    public static let gpio0 = GPIOMask(rawValue: 0x01)
    public static let gpio1 = GPIOMask(rawValue: 0x02)
    public static let gpio2 = GPIOMask(rawValue: 0x04)
    public static let gpio3 = GPIOMask(rawValue: 0x08)
    
    // 预定义的组合
    public static let all: GPIOMask = [.gpio0, .gpio1, .gpio2, .gpio3]
    
    // 提供便捷的初始化方法
    public static func mask(for gpios: GPIOMask...) -> GPIOMask {
        return GPIOMask(gpios)
    }
}

public enum GPIOValue: UInt8 {
    case reset = 0
    case set = 1

    public var cValue: Brg_GpioValT {
        switch self {
        case .reset: return GPIO_RESET
        case .set: return GPIO_SET
        }
    }
}

public enum GPIOMode: UInt8 {
    case input = 0
    case output = 1
    case analog = 3
    
    public var cValue: Brg_GpioModeT {
        switch self {
        case .input: return GPIO_MODE_INPUT
        case .output: return GPIO_MODE_OUTPUT
        case .analog: return GPIO_MODE_ANALOG
        }
    }
}

public enum GPIOSpeed: UInt8 {
    case low = 0
    case medium = 1
    case high = 2
    case veryHigh = 3
    
    public var cValue: Brg_GpioSpeedT {
        switch self {
        case .low: return GPIO_SPEED_LOW
        case .medium: return GPIO_SPEED_MEDIUM
        case .high: return GPIO_SPEED_HIGH
        case .veryHigh: return GPIO_SPEED_VERY_HIGH
        }
    }
}

public enum GPIOPull: UInt8 {
    case none = 0
    case up = 1
    case down = 2
    
    public var cValue: Brg_GpioPullT {
        switch self {
        case .none: return GPIO_NO_PULL
        case .up: return GPIO_PULL_UP
        case .down: return GPIO_PULL_DOWN
        }
    }
}

public enum GPIOOutputType: UInt8 {
    case pushPull = 0
    case openDrain = 1
    
    public var cValue: Brg_GpioOutputT {
        switch self {
        case .pushPull: return GPIO_OUTPUT_PUSHPULL
        case .openDrain: return GPIO_OUTPUT_OPENDRAIN
        }
    }
}

// MARK: - GPIO 枚举 C -> Swift 转换

public extension GPIOValue {
    init(cValue: Brg_GpioValT) {
        switch cValue {
        case GPIO_RESET: self = .reset
        case GPIO_SET: self = .set
        default: self = .reset
        }
    }
}

public extension GPIOMode {
    init(cValue: Brg_GpioModeT) {
        switch cValue {
        case GPIO_MODE_INPUT: self = .input
        case GPIO_MODE_OUTPUT: self = .output
        case GPIO_MODE_ANALOG: self = .analog
        default: self = .output
        }
    }
}

public extension GPIOSpeed {
    init(cValue: Brg_GpioSpeedT) {
        switch cValue {
        case GPIO_SPEED_LOW: self = .low
        case GPIO_SPEED_MEDIUM: self = .medium
        case GPIO_SPEED_HIGH: self = .high
        case GPIO_SPEED_VERY_HIGH: self = .veryHigh
        default: self = .high
        }
    }
}

public extension GPIOPull {
    init(cValue: Brg_GpioPullT) {
        switch cValue {
        case GPIO_NO_PULL: self = .none
        case GPIO_PULL_UP: self = .up
        case GPIO_PULL_DOWN: self = .down
        default: self = .none
        }
    }
}

public extension GPIOOutputType {
    init(cValue: Brg_GpioOutputT) {
        switch cValue {
        case GPIO_OUTPUT_PUSHPULL: self = .pushPull
        case GPIO_OUTPUT_OPENDRAIN: self = .openDrain
        default: self = .pushPull
        }
    }
}

public extension GPIOConfiguration {
    init(cStruct: Brg_GpioConfT) {
        self.mode = GPIOMode(cValue: cStruct.Mode)
        self.speed = GPIOSpeed(cValue: cStruct.Speed)
        self.pull = GPIOPull(cValue: cStruct.Pull)
        self.outputType = GPIOOutputType(cValue: cStruct.OutputType)
    }
} 