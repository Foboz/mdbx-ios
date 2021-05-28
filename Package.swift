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
    .library(
      name: "libmdbx_ios",
      targets: ["libmdbx_ios"])
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
      url: "https://github.com/Foboz/mdbx-ios/releases/download/1.0.2/libmdbx_ios.xcframework.zip",
      checksum: "a3ea2e8d07781690c348ff776bfd3070e925de80c1098848855a772b63c3ef71")
  ]
)
