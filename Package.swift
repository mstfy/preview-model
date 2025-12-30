// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "PreviewModel",
  platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    .library(
      name: "PreviewModel",
      targets: ["PreviewModel"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
  ],
  targets: [
    .macro(
      name: "PreviewModelMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .target(name: "PreviewModel", dependencies: ["PreviewModelMacros"]),
    .testTarget(
      name: "PreviewModelTests",
      dependencies: ["PreviewModel"]
    )
  ]
)
