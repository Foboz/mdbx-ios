//
//  MDBXVal+Data.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/16/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

extension MDBX_val {  
  var data: Data {
    guard iov_base != nil else {
      return Data()
    }
    
    return Data.init(bytes: iov_base, count: iov_len)
  }
  
  var dataNoCopy: Data {
    guard iov_base != nil else {
      return Data()
    }
    
    return Data.init(bytesNoCopy: iov_base, count: iov_len, deallocator: .none)
  }
}
