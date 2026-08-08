// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftWasmUI",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SwiftWasmUI", targets: ["SwiftWasmUI"]),
        .executable(name: "SwiftWasmUIDemo", targets: ["SwiftWasmUIDemo"]),
    ],
    dependencies: [
        // Web/main.js が読み込むランタイム (javascript-kit-swift) とバージョンを揃えること
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", exact: "0.19.2"),
    ],
    targets: [
        .target(
            name: "SwiftWasmUI",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
            ]
        ),
        .executableTarget(
            name: "SwiftWasmUIDemo",
            dependencies: ["SwiftWasmUI"]
        ),
    ]
)
