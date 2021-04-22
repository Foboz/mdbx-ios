//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/21/21.
//

import Foundation
import libmdbx_ios

struct MDBXCommitLatency {
  let preparation: UInt32
  let gc: UInt32
  let audit: UInt32
  let write: UInt32
  let sync: UInt32
  let ending: UInt32
  let whole: UInt32
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
