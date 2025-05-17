# SwiftSTLinkV3Bridge

> 🚀 Swift 封装的 ST-Link V3 Bridge 通信库，支持 I2C/SPI/CAN/GPIO 等多协议，适用于 macOS/Linux 下的硬件自动化、传感器调试、嵌入式开发等场景。

---

## ✨ 特性亮点
- 支持 ST-Link V3 Bridge 全部功能，I2C/SPI/CAN/GPIO 一站式操作
- Swift 现代语法封装，API 简洁易用
- 支持常见传感器/外设（如 SSD1306 OLED、MPU6050 等）
- 适配 Linux，适合自动化测试、仪器控制、原型开发
- 丰富的示例代码，开箱即用

---

## 🛠️ 依赖环境
- Swift 5.10 及以上
- 支持 Linux (x86_64)
- 需连接 ST-Link V3 硬件

---

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/CmST0us/SwiftSTLinkV3Bridge.git
cd SwiftSTLinkV3Bridge
```

### 2. 编译
```bash
swift build
```

### 3. 运行示例
```bash
swift run Bridge
```

---

## 📚 典型用法

### 1. I2C 设备扫描
```swift
let device = SwiftSTLinkV3Bridge.Bridge()
device.enumDevices()
device.openDevice()
device.initI2CDevice(configuration: I2CConfiguration.standard)
for addr in 0x03...0x77 {
    if let _ = device.readI2C(addr: UInt16(addr), length: 1) {
        print(String(format: "发现I2C设备: 0x%02X", UInt8(addr)))
    }
}
```

### 2. SSD1306 OLED 绘制三角形
```swift
// 见 main.swift 示例，支持初始化、清屏、画线、动画等
```

### 3. MPU6050 读取欧拉角
```swift
if let data = device.readI2CRegister(addr: 0x68, register: 0x3B, length: 6) {
    let ax = Int16(data[0]) << 8 | Int16(data[1])
    let ay = Int16(data[2]) << 8 | Int16(data[3])
    let az = Int16(data[4]) << 8 | Int16(data[5])
    let pitch = atan2(-Double(ax), sqrt(Double(ay * ay + az * az))) * 180.0 / .pi
    let roll  = atan2(Double(ay), Double(az)) * 180.0 / .pi
    print("Pitch: \(pitch), Roll: \(roll)")
}
```

---

## 📁 目录结构
```
Sources/
  SwiftSTLinkV3Bridge/   # Swift 封装主库
  Bridge/                # 示例/测试主程序
  CSTLinkV3Bridge/       # C/C++ Bridge 适配层
  CSTSWLink007/          # ST 官方驱动/头文件
```

---

## 🤝 贡献指南
- 欢迎 Issue、PR、文档补充、示例代码！
- 建议遵循 Swift 社区最佳实践，代码注释清晰，接口友好
- 贡献前请先阅读本项目 LICENSE

---

## 📄 License

本项目基于 MIT License 开源，部分底层驱动遵循 ST 官方协议。
