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
    .testTarget(
       name: "mdbx-ios-tests",
       dependencies: ["mdbx-ios"],
       path: "Tests/mdbx-ios-tests"),
    .binaryTarget(
      name: "libmdbx_ios",
      url: "https://github.com/Foboz/mdbx-ios/releases/download/1.0.0/libmdbx_ios.xcframework.zip",
      checksum: "46ce0391693cff2c6c8ba5399df9bc6414770bece8fdad6351635cae228ee5e8")
  ]
)
