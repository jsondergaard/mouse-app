// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MouseTeleporter",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.1.3")
    ],
    targets: [
        .executableTarget(
            name: "MouseTeleporter",
            dependencies: ["HotKey"])
    ]
)
