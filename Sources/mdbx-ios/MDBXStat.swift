//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/20/21.
//

import Foundation

struct MDBXStat {
  // Size of a database page. This is the same for all databases
  let pSize: UInt32
  // Depth (height) of the B-tree
  let depth: UInt32
  // Number of internal (non-leaf) pages
  let branchPages: UInt64
  // Number of leaf pages
  let leafPages: UInt64
  // Number of overflow pages
  let overflowPages: UInt64
  // Number of data items
  let entries: UInt64
  // Transaction ID of committed last modification
  let modTransactionId: UInt64
}

extension MDBXStat {
    static var empty: MDBXStat = .init(
        pSize: 0,
        depth: 0,
        branchPages: 0,
        leafPages: 0,
        overflowPages: 0,
        entries: 0,
        modTransactionId: 0
    )
}
