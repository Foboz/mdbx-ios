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
    return Swift.withUnsafeBytes(of: value) { Data($0) }
  }
  
  static var verySmallInt: Data {
    let value = Int.min
    return Swift.withUnsafeBytes(of: value) { Data($0) }
  }
  
  static var veryLargeInt: Data {
    let value = Int.max
    return Swift.withUnsafeBytes(of: value) { Data($0) }
  }
  
  func toInt() -> Int {
    let value = withUnsafeBytes {
      $0.load(as: Int.self)
    }
    return value
  }
}

extension Int {
  static func asData(value: inout Int) -> Data {
    return Swift.withUnsafeBytes(of: value.bigEndian) {
      Data($0)
    }
  }
}
