//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/14/21.
//

import Foundation
import libmdbx_ios

/**
 * Transaction flags
 *
 * # Reference
 *    - \see mdbx_txn_begin()
 *    - \see mdbx_txn_flags()
 *
 * - Tag: MDBXTransactionFlags
 */
struct MDBXTransactionFlags: OptionSet {
  let rawValue: UInt32
  /**
   * Start read-write transaction.
   *
   * Only one write transaction may be active at a time. Writes are fully serialized, which guarantees that writers can never deadlock.
   *
   * - Tag: MDBXTransactionFlags.readWrite
   */
  static let readWrite = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_READWRITE.rawValue)
  
  /**
   * Start read-only transaction.
   *
   * There can be multiple read-only transactions simultaneously that do not block each other and a write transactions.
   *
   * - Tag: MDBXTransactionFlags.readOnly
   */
  static let readOnly = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_RDONLY.rawValue)
  
  /**
   * Prepare but not start read-only transaction.
   *
   * Transaction will not be started immediately, but created transaction handle will be ready for use with \ref mdbx_txn_renew(). This flag allows to
   * preallocate memory and assign a reader slot, thus avoiding these operations at the next start of the transaction.
   *
   * - Tag: MDBXTransactionFlags.readOnlyPrepare
   */
  static let readOnlyPrepare = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_RDONLY_PREPARE.rawValue)
  
  /**
   * Do not block when starting a write transaction.
   *
   * - Tag: MDBXTransactionFlags.try
   */
  static let `try` = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_TRY.rawValue)
  
  /**
   * Exactly the same as \ref MDBX_NOMETASYNC, but for this transaction only
   *
   * - Tag: MDBXTransactionFlags.noMetaSync
   */
  static let noMetaSync = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_NOMETASYNC.rawValue)
  
  /**
   * Exactly the same as \ref MDBX_SAFE_NOSYNC, but for this transaction only
   *
   * - Tag: MDBXTransactionFlags.noSync
   */
  static let noSync = MDBXTransactionFlags(rawValue: libmdbx_ios.MDBX_TXN_NOSYNC.rawValue)
}

internal extension MDBXTransactionFlags {
  var MDBX_txn_flags_t: MDBX_txn_flags_t {
    libmdbx_ios.MDBX_txn_flags_t(self.rawValue)
  }
}
