//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/16/21.
//

import Foundation
import libmdbx_ios

extension MDBX_val {
  init(data: inout Data) {
    self.init()
    withUnsafeMutableBytes(of: &data, {
      self.iov_base = $0.baseAddress
    })
    self.iov_len = data.count
  }
  
  var data: Data {
    guard iov_base != nil else {
      return Data()
    }
    
    return Data.init(bytes: iov_base, count: iov_len)
  }
}
