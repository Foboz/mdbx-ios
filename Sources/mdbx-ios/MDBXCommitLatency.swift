//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/21/21.
//

import Foundation
import libmdbx_ios

/** \brief Latency of commit stages in 1/65536 of seconds units.
 * \warning This structure may be changed in future releases.
 * \see mdbx_txn_commit_ex() */

public struct MDBXCommitLatency {
  public let preparation: UInt32
  public let gc: UInt32
  public let audit: UInt32
  public let write: UInt32
  public let sync: UInt32
  public let ending: UInt32
  public let whole: UInt32
}

extension MDBXCommitLatency {
  var mdbx_commit_latency: MDBX_commit_latency {
    return .init(
      preparation: preparation,
      gc: gc,
      audit: audit,
      write: write,
      sync: sync,
      ending: ending,
      whole: whole
    )
  }
}
