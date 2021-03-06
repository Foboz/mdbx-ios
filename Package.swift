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
      targets: ["mdbx-ios"]
    )
  ],
  targets: [
    .target(
      name: "mdbx-ios",
      dependencies: [
        "libmdbx"
      ]
    ),
    .testTarget(
      name: "mdbx-ios-tests",
      dependencies: [
        .target(name: "mdbx-ios")
      ],
      path: "Tests/mdbx-ios-tests"
    ),
    .target(
      name: "libmdbx",
      path: "libmdbx",
      exclude: [
        "build/CMakeFiles",
        "build/CMakeScripts",
        "build/CMakeCache.txt",
        "build/cmake_install.cmake",
        "build/test",
        "libmdbx/include",
        "libmdbx/test",
        "libmdbx/packages",
        "libmdbx/example",
        "libmdbx/cmake",
        "libmdbx/docs",
        "libmdbx/CMakeLists.txt",
        "libmdbx/mdbx_drop.c",
        "libmdbx/mdbx.h++",
        "libmdbx/appveyor.yml",
        "libmdbx/AUTHORS",
        "libmdbx/COPYRIGHT",
        "libmdbx/GNUmakefile",
        "libmdbx/Makefile",
        "libmdbx/LICENSE",
        "libmdbx/README.md",
        "libmdbx/ChangeLog.md",
        "libmdbx/src/man1",
        "libmdbx/src/ntdll.def",
        "libmdbx/src/bits.md",
        "libmdbx/src/config.h.in",
        "libmdbx/src/version.c.in",
        "libmdbx/src/wingetopt.c",
        "libmdbx/src/alloy.c",
        "libmdbx/src/lck-windows.c",
        "libmdbx/src/mdbx_drop.c",
        "libmdbx/src/mdbx_chk.c",
        "libmdbx/src/mdbx_copy.c",
        "libmdbx/src/mdbx_stat.c",
        "libmdbx/src/mdbx_load.c",
        "libmdbx/src/mdbx_dump.c",
        "libmdbx/src/mdbx.c++",
      ],
      sources: [
        "build/version.c",
        "libmdbx/src/core.c",
        "libmdbx/src/lck-posix.c",
        "libmdbx/src/osal.c",
      ],
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("."),
        .headerSearchPath("./include"),
        .headerSearchPath("./libmdbx/"),
        .headerSearchPath("./libmdbx/src/"),
        .headerSearchPath("./build"),
        .define("__APPLE__"),
        .define("__STDC_FORMAT_MACROS", to: "1"),
        .define("__STDC_LIMIT_MACROS", to: "1"),
        .define("__STDC_CONSTANT_MACROS", to: "1"),
        .define("_HAS_EXCEPTIONS", to: "1"),
        .define("MDBX_BUILD_SHARED_LIBRARY", to: "0"),
        .define("LIBMDBX_EXPORTS", to: "1"),
        .define("MDBX_DEBUG", to: "1", .when(configuration: .debug)),
        .define("MDBX_BUILD_TYPE", to: "\"Debug\"", .when(configuration: .debug)),
        .define("MDBX_BUILD_TYPE", to: "\"Release\"", .when(configuration: .release)),
//        .unsafeFlags([
//          "-fexceptions", "-fno-common", "-Wno-unknown-pragmas", "-Wall", "-Wextra", "-Werror",
//          "-flto=thin", "-Wno-error=shorten-64-to-32", "-fPIC", "-ffast-math", "-fvisibility=hidden",
//          "-ggdb"
//        ], .when(configuration: .debug)),
//        .unsafeFlags([
//          "-fexceptions", "-fno-common", "-Wno-unknown-pragmas", "-Wall", "-Wextra", "-Werror",
//          "-flto=thin", "-Wno-error=shorten-64-to-32", "-fPIC", "-ffast-math", "-fvisibility=hidden",
//        ], .when(configuration: .release)),
      ],
      cxxSettings: [
        .headerSearchPath("."),
        .headerSearchPath("./include"),
        .headerSearchPath("./libmdbx/"),
        .headerSearchPath("./libmdbx/src/"),
        .headerSearchPath("./build"),
        .define("__APPLE__"),
        .define("MDBX_CONFIG_H", to: "\"../../build/config.h\""),
        .define("__STDC_FORMAT_MACROS", to: "1"),
        .define("__STDC_LIMIT_MACROS", to: "1"),
        .define("__STDC_CONSTANT_MACROS", to: "1"),
        .define("_HAS_EXCEPTIONS", to: "1"),
        .define("MDBX_BUILD_SHARED_LIBRARY", to: "0"),
        .define("LIBMDBX_EXPORTS", to: "1"),
        .define("MDBX_DEBUG", to: "1", .when(configuration: .debug)),
        .define("MDBX_BUILD_TYPE", to: "\"Debug\"", .when(configuration: .debug)),
        .define("MDBX_BUILD_TYPE", to: "\"Release\"", .when(configuration: .release)),
//        .unsafeFlags([
//          "-fexceptions", "-fcxx-exceptions", "-frtti", "-fno-common", "-Wno-unknown-pragmas",
//          "-Wall", "-Wextra", "-Werror", "-flto=thin", "-fPIC", "-ffast-math", "-fvisibility=hidden",
//          "-g"
//        ], .when(configuration: .debug)),
//        .unsafeFlags([
//          "-fexceptions", "-fcxx-exceptions", "-frtti", "-fno-common", "-Wno-unknown-pragmas",
//          "-Wall", "-Wextra", "-Werror", "-flto=thin", "-DNDEBUG", "-fPIC", "-ffast-math",
//          "-fvisibility=hidden",
//        ], .when(configuration: .release)),
      ],
      linkerSettings: [
        .linkedLibrary("c++")
      ]
    )
  ],
  cLanguageStandard: .gnu11,
  cxxLanguageStandard: .gnucxx1z
)
