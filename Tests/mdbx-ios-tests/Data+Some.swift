//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/26/21.
//

import Foundation

extension Data {
  static var some: Data {
    return "some".data(using: .utf8)!
  }
  
  static var any: Data {
    return "any".data(using: .utf8)!
  }
  
  static var someInt: Data {
    let value = 77
    return Swift.withUnsafeBytes(of: value.bigEndian) { Data($0) }
  }
  
  static var verySmallInt: Data {
    let value = Int.min
    return Swift.withUnsafeBytes(of: value.bigEndian) { Data($0) }
  }
  
  static var veryLargeInt: Data {
    let value = Int.max
    return Swift.withUnsafeBytes(of: value.bigEndian) { Data($0) }
  }
  
  func toInt() -> Int {
    let value = withUnsafeBytes {
      $0.load(as: Int.self)
    }
    return Int(bigEndian: value)
  }
}

extension Int {
  static func asData(value: inout Int) -> Data {
    return Swift.withUnsafeBytes(of: value.bigEndian) {
      Data($0)
    }
  }
}

extension Data {
  public init(hex: String) {
    self.init(Array<UInt8>(hex: hex))
  }

  public var bytes: Array<UInt8> {
    Array(self)
  }

  public func toHexString() -> String {
    self.bytes.toHexString()
  }
}

extension Array where Element == UInt8 {
  public func toHexString() -> String {
    `lazy`.reduce(into: "") {
      var s = String($1, radix: 16)
      if s.count == 1 {
        s = "0" + s
      }
      $0 += s
    }
  }
  
  public init(hex: String) {
      self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
      var buffer: UInt8?
      var skip = hex.hasPrefix("0x") ? 2 : 0
      for char in hex.unicodeScalars.lazy {
        guard skip == 0 else {
          skip -= 1
          continue
        }
        guard char.value >= 48 && char.value <= 102 else {
          removeAll()
          return
        }
        let v: UInt8
        let c: UInt8 = UInt8(char.value)
        switch c {
          case let c where c <= 57:
            v = c - 48
          case let c where c >= 65 && c <= 70:
            v = c - 55
          case let c where c >= 97:
            v = c - 87
          default:
            removeAll()
            return
        }
        if let b = buffer {
          append(b << 4 | v)
          buffer = nil
        } else {
          buffer = v
        }
      }
      if let b = buffer {
        append(b)
      }
    }
}

extension Array {
  init(reserveCapacity: Int) {
    self = Array<Element>()
    self.reserveCapacity(reserveCapacity)
  }

  var slice: ArraySlice<Element> {
    self[self.startIndex ..< self.endIndex]
  }
}
