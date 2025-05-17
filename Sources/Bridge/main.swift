import SwiftSTLinkV3Bridge
import Foundation

let device = SwiftSTLinkV3Bridge.Bridge()
device.enumDevices()
device.openDevice()
device.testDevice()

// 配置 I2C
let i2cConfig = I2CConfiguration.fastPlus
device.initI2CDevice(configuration: i2cConfig)

// print("开始扫描 I2C 设备...")
// print("地址\t设备")
// print("----------------")

// // 扫描所有可能的 I2C 地址（0x00-0x7F）
// for addr in 0x00...0x7F {
//     let i2cAddr = I2CAddress.address7Bit(UInt8(addr))
//     if let _ = device.readI2C(addr: UInt16(i2cAddr.address7Bit!), length: 1) {
//         print(String(format: "0x%02X\t已响应", addr))
//     }
// }

// print("扫描完成")


var spiConfiguration = SPIDeviceConfiguration.default
spiConfiguration.nss = .soft
device.initSPI(configuration: spiConfiguration)
device.setSPINss(level: .low)

let rstConfiguration = GPIOConfiguration.pushPullOutput
device.initGPIO(mask: .gpio0, config: [rstConfiguration])

let nssConfiguration = GPIOConfiguration.pushPullOutput
device.initGPIO(mask: .gpio1, config: [nssConfiguration])

// === 调用示例 ===

func testSSD1306() {
    let ssd1306Addr: UInt8 = 0x3C // 7位地址
    print("让三角形转起来...")
    drawRotatingTriangleOnSSD1306(device, addr: ssd1306Addr, duration: 500.0, fps: 120.0)
    print("动画结束！")
}

testSSD1306()