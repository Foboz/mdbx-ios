//
//  MDBXTransaction+Meta.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/22/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

public extension MDBXTransaction {
  /** \brief Determines whether the given address is on a dirty database page of
   * the transaction or not. \ingroup c_statinfo
   *
   * Ultimately, this allows to avoid copy data from non-dirty pages.
   *
   * "Dirty" pages are those that have already been changed during a write
   * transaction. Accordingly, any further changes may result in such pages being
   * overwritten. Therefore, all functions libmdbx performing changes inside the
   * database as arguments should NOT get pointers to data in those pages. In
   * turn, "not dirty" pages before modification will be copied.
   *
   * In other words, data from dirty pages must either be copied before being
   * passed as arguments for further processing or rejected at the argument
   * validation stage. Thus, `mdbx_is_dirty()` allows you to get rid of
   * unnecessary copying, and perform a more complete check of the arguments.
   *
   * \note The address passed must point to the beginning of the data. This is
   * the only way to ensure that the actual page header is physically located in
   * the same memory page, including for multi-pages with long data.
   *
   * \note In rare cases the function may return a false positive answer
   * (\ref MDBX_RESULT_TRUE when data is NOT on a dirty page), but never a false
   * negative if the arguments are correct.
   *
   * \param [in] txn      A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] ptr      The address of data to check.
   *
   * \returns A MDBX_RESULT_TRUE or MDBX_RESULT_FALSE value,
   *          otherwise the error code:
   * \retval MDBX_RESULT_TRUE    Given address is on the dirty page.
   * \retval MDBX_RESULT_FALSE   Given address is NOT on the dirty page.
   * \retval Otherwise the error code. */

  func isDirty(data: inout Data) throws -> Bool {
      let result = withUnsafeMutableBytes(of: &data) { pointer in
          return mdbx_is_dirty(_txn, pointer.baseAddress)
      }
      
      if result == MDBX_RESULT_TRUE.rawValue || result == MDBX_RESULT_FALSE.rawValue {
          return result == MDBX_RESULT_TRUE.rawValue
      } else if let error = MDBXError(code: result) {
          throw error
      } else {
          throw MDBXError.EINVAL
      }
  }
  
  /** \brief Return the transaction's ID.
   * \ingroup c_statinfo
   *
   * This returns the identifier associated with this transaction. For a
   * read-only transaction, this corresponds to the snapshot being read;
   * concurrent readers will frequently have the same transaction ID.
   *
   *
   * \returns A transaction ID, valid if input is an active transaction,
   *          otherwise 0. */

  var id: UInt64 {
    mdbx_txn_id(_txn)
  }
  
  /** \brief Return information about the MDBX transaction.
   * \ingroup c_statinfo
   *
   * \param [in] txn        A transaction handle returned by \ref mdbx_txn_begin()
   * \param [out] info      The address of an \ref MDBX_txn_info structure
   *                        where the information will be copied.
   * \param [in] scan_rlt   The boolean flag controls the scan of the read lock
   *                        table to provide complete information. Such scan
   *                        is relatively expensive and you can avoid it
   *                        if corresponding fields are not needed.
   *                        See description of \ref MDBX_txn_info.
   *
   * \returns A non-zero error value on failure and 0 on success. */

  func getInfo(scanRlt: Bool) throws -> MDBXTransactionInfo {
    var info = MDBX_txn_info()
    try withUnsafeMutablePointer(to: &info) { pointer in
      let code = mdbx_txn_info(_txn, pointer, scanRlt)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      
      throw error
    }
    
    return .init(
      id: info.txn_id,
      readerLag: info.txn_reader_lag,
      spaceUsed: info.txn_space_used,
      spaceLimitSoft: info.txn_space_limit_soft,
      spaceLimitHard: info.txn_space_limit_hard,
      spaceRetired: info.txn_space_retired,
      spaceLeftOver: info.txn_space_leftover,
      spaceDirty: info.txn_space_dirty
    )
  }
}

