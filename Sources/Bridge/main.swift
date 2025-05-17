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

// === SSD1306 OLED 相关函数 ===

func ssd1306_sendCommand(_ device: Bridge, addr: UInt8, cmd: UInt8) {
    let control: UInt8 = 0x00 // 控制字节，表示后面是命令
    _ = device.writeI2C(addr: UInt16(addr), data: [control, cmd])
}

func ssd1306_sendData(_ device: Bridge, addr: UInt8, data: [UInt8]) {
    let control: UInt8 = 0x40 // 控制字节，表示后面是数据
    var payload = [control]
    payload.append(contentsOf: data)
    _ = device.writeI2C(addr: UInt16(addr), data: payload)
}

func ssd1306_init(_ device: Bridge, addr: UInt8) {
    let cmds: [UInt8] = [
        0xAE, // 关闭显示
        0x20, 0x00, // 设置内存寻址模式为水平
        0xB0, // 设置页地址为0
        0xC8, // 扫描方向
        0x00, // 低列起始地址
        0x10, // 高列起始地址
        0x40, // 起始行
        0x81, 0x7F, // 对比度
        0xA1, // 段重定向
        0xA6, // 正常显示
        0xA8, 0x3F, // 多路复用比
        0xA4, // 输出跟随RAM内容
        0xD3, 0x00, // 显示偏移
        0xD5, 0x80, // 时钟分频
        0xD9, 0xF1, // 预充电周期
        0xDA, 0x12, // COM引脚配置
        0xDB, 0x40, // VCOMH电压倍率
        0x8D, 0x14, // 使能电荷泵
        0xAF // 开启显示
    ]
    for cmd in cmds {
        ssd1306_sendCommand(device, addr: addr, cmd: cmd)
    }
}

func ssd1306_clear(_ device: Bridge, addr: UInt8) {
    for page in 0..<8 {
        ssd1306_sendCommand(device, addr: addr, cmd: 0xB0 | UInt8(page)) // 设置页地址
        ssd1306_sendCommand(device, addr: addr, cmd: 0x00) // 低列
        ssd1306_sendCommand(device, addr: addr, cmd: 0x10) // 高列
        ssd1306_sendData(device, addr: addr, data: [UInt8](repeating: 0x00, count: 128))
    }
}

func drawLine(buffer: inout [[UInt8]], x0: Int, y0: Int, x1: Int, y1: Int) {
    var x0 = x0, y0 = y0
    let dx = abs(x1 - x0), sx = x0 < x1 ? 1 : -1
    let dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1
    var err = dx + dy
    while true {
        if x0 >= 0 && x0 < 128 && y0 >= 0 && y0 < 64 {
            buffer[y0][x0] = 1
        }
        if x0 == x1 && y0 == y1 { break }
        let e2 = 2 * err
        if e2 >= dy { err += dy; x0 += sx }
        if e2 <= dx { err += dx; y0 += sy }
    }
}

func drawTriangleOnSSD1306(_ device: Bridge, addr: UInt8) {
    // 1. 初始化
    ssd1306_init(device, addr: addr)
    // 2. 清屏
    ssd1306_clear(device, addr: addr)
    // 3. 画三角形
    var buffer = Array(repeating: Array(repeating: UInt8(0), count: 128), count: 64)
    drawLine(buffer: &buffer, x0: 64, y0: 16, x1: 32, y1: 48)
    drawLine(buffer: &buffer, x0: 32, y0: 48, x1: 96, y1: 48)
    drawLine(buffer: &buffer, x0: 96, y0: 48, x1: 64, y1: 16)
    // 4. 刷新到屏幕
    for page in 0..<8 {
        ssd1306_sendCommand(device, addr: addr, cmd: 0xB0 | UInt8(page))
        ssd1306_sendCommand(device, addr: addr, cmd: 0x00)
        ssd1306_sendCommand(device, addr: addr, cmd: 0x10)
        var pageData = [UInt8](repeating: 0, count: 128)
        for col in 0..<128 {
            var byte: UInt8 = 0
            for bit in 0..<8 {
                if buffer[page * 8 + bit][col] != 0 {
                    byte |= (1 << bit)
                }
            }
            pageData[col] = byte
        }
        ssd1306_sendData(device, addr: addr, data: pageData)
    }
}

func rotatePoint(cx: Double, cy: Double, x: Double, y: Double, angle: Double) -> (Double, Double) {
    let s = sin(angle)
    let c = cos(angle)
    let nx = c * (x - cx) - s * (y - cy) + cx
    let ny = s * (x - cx) + c * (y - cy) + cy
    return (nx, ny)
}

func drawRotatingTriangleOnSSD1306(_ device: Bridge, addr: UInt8, duration: Double = 10.0, fps: Double = 20.0) {
    ssd1306_init(device, addr: addr)
    let width = 128, height = 64
    let cx = Double(width / 2)
    let cy = Double(height / 2)
    let r = 28.0 // 三角形外接圆半径
    let baseAngle = -Double.pi / 2 // 让三角形初始顶点朝上
    let frameCount = Int(duration * fps)
    let delay = 1.0 / fps

    for frame in 0..<frameCount {
        let angle = baseAngle + Double(frame) * (2 * Double.pi / 180) // 每帧旋转2°
        // 计算三个顶点
        let (x0, y0) = rotatePoint(cx: cx, cy: cy, x: cx, y: cy - r, angle: angle)
        let (x1, y1) = rotatePoint(cx: cx, cy: cy, x: cx - r * cos(.pi/6), y: cy + r * sin(.pi/6), angle: angle)
        let (x2, y2) = rotatePoint(cx: cx, cy: cy, x: cx + r * cos(.pi/6), y: cy + r * sin(.pi/6), angle: angle)

        // 清屏
        // ssd1306_clear(device, addr: addr)
        // 画三角形
        var buffer = Array(repeating: Array(repeating: UInt8(0), count: width), count: height)
        drawLine(buffer: &buffer, x0: Int(x0), y0: Int(y0), x1: Int(x1), y1: Int(y1))
        drawLine(buffer: &buffer, x0: Int(x1), y0: Int(y1), x1: Int(x2), y1: Int(y2))
        drawLine(buffer: &buffer, x0: Int(x2), y0: Int(y2), x1: Int(x0), y1: Int(y0))
        // 刷新到屏幕
        for page in 0..<8 {
            ssd1306_sendCommand(device, addr: addr, cmd: 0xB0 | UInt8(page))
            ssd1306_sendCommand(device, addr: addr, cmd: 0x00)
            ssd1306_sendCommand(device, addr: addr, cmd: 0x10)
            var pageData = [UInt8](repeating: 0, count: 128)
            for col in 0..<128 {
                var byte: UInt8 = 0
                for bit in 0..<8 {
                    if buffer[page * 8 + bit][col] != 0 {
                        byte |= (1 << bit)
                    }
                }
                pageData[col] = byte
            }
            ssd1306_sendData(device, addr: addr, data: pageData)
        }
        // 延时
        Thread.sleep(forTimeInterval: delay)
    }
}

// === 调用示例 ===
let ssd1306Addr: UInt8 = 0x3C // 7位地址
print("让三角形转起来...")
drawRotatingTriangleOnSSD1306(device, addr: ssd1306Addr, duration: 500.0, fps: 120.0)
print("动画结束！")

