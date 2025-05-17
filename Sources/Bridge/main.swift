import SwiftSTLinkV3Bridge
import Foundation

let device = SwiftSTLinkV3Bridge.Bridge()
device.enumDevices()
device.openDevice()
device.testDevice()

let i2cConfiguration = I2CConfiguration.fastPlus
device.initI2CDevice(configuration: i2cConfiguration)

print("开始扫描I2C设备...")

let addr = I2CAddress.address8BitWrite(0x78)
// 尝试读取1字节
if let _ = device.readI2C(addr: UInt16(addr.address7Bit!), length: 1) {
    print(String(format: "发现I2C设备: 0x%02X", addr.address7Bit!))
}

// === 调用示例 ===

func testSSD1306() {
    let ssd1306Addr: UInt8 = 0x3C // 7位地址
    print("让三角形转起来...")
    drawRotatingTriangleOnSSD1306(device, addr: ssd1306Addr, duration: 500.0, fps: 120.0)
    print("动画结束！")
}

testSSD1306()

