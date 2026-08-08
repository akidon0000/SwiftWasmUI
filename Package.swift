// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WasmUI",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "WasmUI", targets: ["WasmUI"]),
        .executable(name: "WasmUIDemo", targets: ["WasmUIDemo"]),
    ],
    dependencies: [
        // Web/main.js が読み込むランタイム (javascript-kit-swift) とバージョンを揃えること
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", exact: "0.19.2"),
    ],
    targets: [
        .target(
            name: "WasmUI",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit", condition: .when(platforms: [.wasi])),
            ]
        ),
        .executableTarget(
            name: "WasmUIDemo",
            dependencies: ["WasmUI"]
        ),
    ]
)
