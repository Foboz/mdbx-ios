//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/21/21.
//

import Foundation
import libmdbx_ios

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
    return libmdbx_ios.MDBX_dbi_state_t(rawValue)
  }
}
