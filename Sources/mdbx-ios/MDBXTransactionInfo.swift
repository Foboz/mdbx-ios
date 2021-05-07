//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/20/21.
//

import Foundation

public struct MDBXTransactionInfo {
  // The ID of the transaction. For a READ-ONLY transaction, this corresponds to the snapshot being read.
  public let id: UInt64
  
  /** For READ-ONLY transaction: the lag from a recent MVCC-snapshot, i.e. the
     number of committed transaction since read transaction started.
     For WRITE transaction (provided if `scan_rlt=true`): the lag of the oldest
     reader from current transaction (i.e. at least 1 if any reader running). */
  public let readerLag: UInt64

  /** Used space by this transaction, i.e. corresponding to the last used
   * database page. */
  public let spaceUsed: UInt64

  /** Current size of database file. */
  public let spaceLimitSoft: UInt64

  /** Upper bound for size the database file, i.e. the value `size_upper`
     argument of the appropriate call of \ref mdbx_env_set_geometry(). */
  public let spaceLimitHard: UInt64

  /** For READ-ONLY transaction: The total size of the database pages that were
     retired by committed write transactions after the reader's MVCC-snapshot,
     i.e. the space which would be freed after the Reader releases the
     MVCC-snapshot for reuse by completion read transaction.
     For WRITE transaction: The summarized size of the database pages that were
     retired for now due Copy-On-Write during this transaction. */
  public let spaceRetired: UInt64

  /** For READ-ONLY transaction: the space available for writer(s) and that
     must be exhausted for reason to call the Handle-Slow-Readers callback for
     this read transaction.
     For WRITE transaction: the space inside transaction
     that left to `MDBX_TXN_FULL` error. */
  public let spaceLeftOver: UInt64

  /** For READ-ONLY transaction (provided if `scan_rlt=true`): The space that
     actually become available for reuse when only this transaction will be
     finished.
     For WRITE transaction: The summarized size of the dirty database
     pages that generated during this transaction. */
  public let spaceDirty: UInt64
}
