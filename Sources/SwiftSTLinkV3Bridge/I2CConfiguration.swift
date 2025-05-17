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
