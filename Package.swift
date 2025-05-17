// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "SwiftSTLinkV3Bridge",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftSTLinkV3Bridge",
            targets: ["SwiftSTLinkV3Bridge"]),
    ],
    targets: [
        .executableTarget(
            name: "Bridge", 
            dependencies: [
                .target(name: "SwiftSTLinkV3Bridge")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-cxx-interoperability-mode=default"
                ])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath=\(URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Sources/CSTSWLink007/linux_x64").path)",
                    "-L", "Sources/CSTSWLink007/linux_x64",
                    "-lSTLinkUSBDriver",
                    "-lm"
                ])
            ]
            ),

        .target(
            name: "SwiftSTLinkV3Bridge",
            dependencies: [
                .target(name: "CSTLinkV3Bridge")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-cxx-interoperability-mode=default"
                ])
            ]),

        .target(name: "CSTLinkV3Bridge")
    ]
)
