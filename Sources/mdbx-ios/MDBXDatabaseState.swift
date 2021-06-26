//
//  MDBXDatabaseState.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/21/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

public struct MDBXDatabseState: OptionSet {
  public let rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  // DB was written in this txn
  public static let dirty: MDBXDatabseState = .init(rawValue: MDBX_DBI_DIRTY.rawValue)
  
  /** Named-DB record is older than txnID */
  public static let stale: MDBXDatabseState = .init(rawValue: MDBX_DBI_STALE.rawValue)
  
  /** Named-DB handle opened in this txn */
  public static let fresh: MDBXDatabseState = .init(rawValue: MDBX_DBI_FRESH.rawValue)
  
  /** Named-DB handle created in this txn */
  public static let created: MDBXDatabseState = .init(rawValue: MDBX_DBI_CREAT.rawValue)
}

internal extension MDBXDatabseState {
  var MDBX_dbi_state_t: MDBX_dbi_state_t {
    return libmdbx.MDBX_dbi_state_t(rawValue)
  }
}
