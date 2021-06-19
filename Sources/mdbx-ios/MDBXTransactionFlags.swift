//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/14/21.
//

import Foundation
import libmdbx

/**
 * Transaction flags
 *
 * # Reference
 *    - \see mdbx_txn_begin()
 *    - \see mdbx_txn_flags()
 *
 * - Tag: MDBXTransactionFlags
 */
public struct MDBXTransactionFlags: OptionSet {
  public let rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  /**
   * Start read-write transaction.
   *
   * Only one write transaction may be active at a time. Writes are fully serialized, which guarantees that writers can never deadlock.
   *
   * - Tag: MDBXTransactionFlags.readWrite
   */
  public static let readWrite = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_READWRITE.rawValue)
  
  /**
   * Start read-only transaction.
   *
   * There can be multiple read-only transactions simultaneously that do not block each other and a write transactions.
   *
   * - Tag: MDBXTransactionFlags.readOnly
   */
  public static let readOnly = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_RDONLY.rawValue)
  
  /**
   * Prepare but not start read-only transaction.
   *
   * Transaction will not be started immediately, but created transaction handle will be ready for use with \ref mdbx_txn_renew(). This flag allows to
   * preallocate memory and assign a reader slot, thus avoiding these operations at the next start of the transaction.
   *
   * - Tag: MDBXTransactionFlags.readOnlyPrepare
   */
  public static let readOnlyPrepare = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_RDONLY_PREPARE.rawValue)
  
  /**
   * Do not block when starting a write transaction.
   *
   * - Tag: MDBXTransactionFlags.try
   */
  public static let `try` = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_TRY.rawValue)
  
  /**
   * Exactly the same as \ref MDBX_NOMETASYNC, but for this transaction only
   *
   * - Tag: MDBXTransactionFlags.noMetaSync
   */
  public static let noMetaSync = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_NOMETASYNC.rawValue)
  
  /**
   * Exactly the same as \ref MDBX_SAFE_NOSYNC, but for this transaction only
   *
   * - Tag: MDBXTransactionFlags.noSync
   */
  public static let noSync = MDBXTransactionFlags(rawValue: libmdbx.MDBX_TXN_NOSYNC.rawValue)
}

internal extension MDBXTransactionFlags {
  var MDBX_txn_flags_t: MDBX_txn_flags_t {
    libmdbx.MDBX_txn_flags_t(self.rawValue)
  }
}
