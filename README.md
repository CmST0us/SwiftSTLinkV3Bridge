# SwiftSTLinkV3Bridge

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20|%20Linux-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

SwiftSTLinkV3Bridge 是一个用 Swift 编写的 ST-Link V3 编程器通信库，提供了与 ST-Link V3 设备进行通信的高级 API。该库支持 SPI、I2C、GPIO 等接口，可以方便地进行设备编程和调试。

## ✨ 特性

- 🚀 支持 ST-Link V3 设备
- 🔌 支持多种通信接口：
  - SPI 接口（支持软件/硬件 NSS）
  - I2C 接口（支持标准/快速/快速+模式）
  - GPIO 接口（支持输入/输出/模拟模式）
- 📦 纯 Swift 实现，无需依赖其他语言
- 🎯 支持 macOS 和 Linux 平台

## 📋 系统要求

- Swift 5.10 或更高版本
- Linux
- ST-Link V3 编程器

## 🚀 快速开始

### 安装

1. 克隆仓库：
```bash
git clone https://github.com/CmST0us/SwiftSTLinkV3Bridge.git
cd SwiftSTLinkV3Bridge
```

2. 构建项目：
```bash
swift build
```

### 在其他项目中使用

在您的 Swift Package Manager 项目中添加依赖：

```swift
// swift-tools-version: 5.10
import PackageDescription

let SwiftSTLinkV3BridgePath = URL(fileURLWithPath: ".").appendingPathComponent(".build/checkouts/SwiftSTLinkV3Bridge")

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/CmST0us/SwiftSTLinkV3Bridge.git", branch: "main")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "SwiftSTLinkV3Bridge", package: "SwiftSTLinkV3Bridge")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-cxx-interoperability-mode=default"
                ])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath=\(SwiftSTLinkV3BridgePath.path)/Sources/CSTSWLink007/linux_x64",
                    "-L", "\(SwiftSTLinkV3BridgePath.path)/Sources/CSTSWLink007/linux_x64",
                    "-lSTLinkUSBDriver",
                    "-lm"
                ])
            ])
    ]
)
```

注意：在 Linux 平台上使用时，需要确保正确配置链接器设置以包含 ST-Link USB 驱动。

### 使用示例

#### 初始化设备

```swift
import SwiftSTLinkV3Bridge

let device = SwiftSTLinkV3Bridge.Bridge()
device.enumDevices()
device.openDevice()
device.testDevice()
```

#### 配置 SPI 接口

```swift
var spiConfiguration = SPIDeviceConfiguration.default
spiConfiguration.nss = .soft
device.initSPI(configuration: spiConfiguration)
device.setSPINss(level: .low)
```

#### 配置 GPIO

```swift
let rstConfiguration = GPIOConfiguration.pushPullOutput
device.initGPIO(mask: .gpio0, config: [rstConfiguration])
```


## 📚 API 文档

### Bridge 类

主要的设备通信类，提供以下功能：

- 设备枚举和连接
- SPI 接口配置和通信
- I2C 接口配置和通信
- GPIO 配置和控制

### 配置类

- `SPIDeviceConfiguration`: SPI 设备配置
- `I2CConfiguration`: I2C 设备配置
- `GPIOConfiguration`: GPIO 配置

## 🤝 贡献

欢迎提交 Pull Request 和 Issue！在提交之前，请确保：

1. 代码符合项目的编码规范
2. 添加了必要的测试
3. 更新了相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [ST-Link V3 固件](https://www.st.com/en/development-tools/stlink-v3.html)
- [Swift Package Manager](https://swift.org/package-manager/)
