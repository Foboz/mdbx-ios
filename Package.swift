// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "mdbx-ios",
  platforms: [.iOS(.v11),
              .macOS(.v10_15)],
  products: [
    .library(
      name: "mdbx-ios",
      targets: ["mdbx-ios"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "mdbx-ios",
      dependencies: ["mdbx-framework"]),
    .binaryTarget(name: "mdbx-framework",
                  path: "mdbx_framework.xcframework.zip")
  ]
)
