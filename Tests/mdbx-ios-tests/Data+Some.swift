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
}
