//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/16/21.
//

import Foundation
import libmdbx_ios

extension Data {
  var mdbxVal: MDBX_val {
    var data = self
    
    return data.withUnsafeMutableBytes { pointer in
      return MDBX_val(iov_base: pointer.baseAddress, iov_len: pointer.count)
    }
  }
}
