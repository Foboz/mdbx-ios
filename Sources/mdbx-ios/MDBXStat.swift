//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/20/21.
//

import Foundation

public struct MDBXStat {
  // Size of a database page. This is the same for all databases
  public let pSize: UInt32
  // Depth (height) of the B-tree
  public let depth: UInt32
  // Number of internal (non-leaf) pages
  public let branchPages: UInt64
  // Number of leaf pages
  public let leafPages: UInt64
  // Number of overflow pages
  public let overflowPages: UInt64
  // Number of data items
  public let entries: UInt64
  // Transaction ID of committed last modification
  public let modTransactionId: UInt64
}

extension MDBXStat {
    public static var empty: MDBXStat = .init(
        pSize: 0,
        depth: 0,
        branchPages: 0,
        leafPages: 0,
        overflowPages: 0,
        entries: 0,
        modTransactionId: 0
    )
}
