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
      targets: ["libmdbx_ios"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "mdbx-ios",
      dependencies: ["libmdbx_ios"]),
    .binaryTarget(
      name: "libmdbx_ios",
      url: "https://github.com/Foboz/mdbx-ios/releases/download/1.0.1/libmdbx_ios.xcframework.zip",
      checksum: "9500b0db7b5090d6b00ab28d72e5a9ba5cdce58a399061e3a30df01249253406")
  ]
)
