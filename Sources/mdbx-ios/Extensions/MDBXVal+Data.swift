//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/16/21.
//

import Foundation
import libmdbx_ios

extension MDBX_val {
  var data: Data {
    Data(
      bytesNoCopy: iov_base,
      count: iov_len,
      deallocator: .none
    )
  }
}
