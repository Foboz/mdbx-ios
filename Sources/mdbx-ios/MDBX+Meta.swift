//
//  MDBX+Meta.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/20/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

/** \brief The shortcut to calling \ref mdbx_dbi_flags_ex() with `state=NULL`
 * for discarding it result. \ingroup c_statinfo */
public func databaseFlags(transaction: MDBXTransaction, database: MDBXDatabase, flags: inout MDBXDatabaseFlags) throws {
  var rawValue: UInt32 = 0
  try withUnsafeMutablePointer(to: &rawValue) { pointer in
    let code = mdbx_dbi_flags(transaction._txn, database._dbi, pointer)
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  flags = MDBXDatabaseFlags(rawValue: rawValue)
}

/** \brief Retrieve the DB flags and status for a database handle.
 * \ingroup c_statinfo
 *
 * \param [in] txn     A transaction handle returned by \ref mdbx_txn_begin().
 * \param [in] dbi     A database handle returned by \ref mdbx_dbi_open().
 * \param [out] flags  Address where the flags will be returned.
 * \param [out] state  Address where the state will be returned.
 *
 * \returns A non-zero error value on failure and 0 on success. */

public func databaseFlagsEx(
  transaction: MDBXTransaction,
  database: MDBXDatabase,
  flags: inout MDBXDatabaseFlags,
  state: inout MDBXDatabseState
) throws {
  var flagRawValue: UInt32 = 0
  var stateRawValue: UInt32 = 0
  
  try withUnsafeMutablePointer(to: &flagRawValue, { flagPointer in
    try withUnsafeMutablePointer(to: &stateRawValue, { statePointer in
      let code = mdbx_dbi_flags_ex(transaction._txn, database._dbi, flagPointer, statePointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    })
  })
  
  flags = MDBXDatabaseFlags(rawValue: flagRawValue)
  state = MDBXDatabseState(rawValue: stateRawValue)
}

/** \brief Retrieve depth (bitmask) information of nested dupsort (multi-value)
 * B+trees for given database.
 * \ingroup c_statinfo
 *
 * \param [in] txn     A transaction handle returned by \ref mdbx_txn_begin().
 * \param [in] dbi     A database handle returned by \ref mdbx_dbi_open().
 * \param [out] mask   The address of an uint32_t value where the bitmask
 *                     will be stored.
 *
 * \returns A non-zero error value on failure and 0 on success,
 *          some possible errors are:
 * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
 *                               by current thread.
 * \retval MDBX_EINVAL       An invalid parameter was specified.
 * \retval MDBX_RESULT_TRUE  The dbi isn't a dupsort (multi-value) database. */

public func databaseDupSortDepthMask(transaction: MDBXTransaction, database: MDBXDatabase, mask: inout UInt32) throws {
    try withUnsafeMutablePointer(to: &mask) { pointer in
        let code = mdbx_dbi_dupsort_depthmask(transaction._txn, database._dbi, pointer)
        guard code != 0, let error = MDBXError(code: code) else {
          return
        }
        throw error
    }
}

/** \brief Retrieve statistics for a database.
 * \ingroup c_statinfo
 *
 * \param [in] txn     A transaction handle returned by \ref mdbx_txn_begin().
 * \param [in] dbi     A database handle returned by \ref mdbx_dbi_open().
 * \param [out] stat   The address of an \ref MDBX_stat structure where
 *                     the statistics will be copied.
 * \param [in] bytes   The size of \ref MDBX_stat.
 *
 * \returns A non-zero error value on failure and 0 on success,
 *          some possible errors are:
 * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
 *                               by current thread.
 * \retval MDBX_EINVAL   An invalid parameter was specified. */

// TODO: check with tests
public func databaseStat(transaction: MDBXTransaction, database: MDBXDatabase) throws -> MDBXStat {
    var stat = MDBX_stat()
    let size = MemoryLayout.size(ofValue: stat)
    
    try withUnsafeMutablePointer(to: &stat) { pointer in
        let code = mdbx_dbi_stat(transaction._txn, database._dbi, pointer, size)
        
        guard code != 0, let error = MDBXError(code: code) else {
          return
        }
        throw error
    }
    
    return .init(
        pSize: stat.ms_psize,
        depth: stat.ms_depth,
        branchPages: stat.ms_branch_pages,
        leafPages: stat.ms_leaf_pages,
        overflowPages: stat.ms_overflow_pages,
        entries: stat.ms_entries,
        modTransactionId: stat.ms_mod_txnid
    )
}

/** \brief Returns the default size of database page for the current system.
 * \ingroup c_statinfo
 * \details Default size of database page depends on the size of the system
 * page and usually exactly match it. */

public func defaultPageSize() -> Int {
    return mdbx_default_pagesize()
}

/** \brief Returns basic information about system RAM.
 * \ingroup c_statinfo
 */

public func getSysRamInfo(pageSize: inout Int, totalPages: inout Int, availPages: inout Int) {
    _ = withUnsafeMutablePointer(to: &pageSize) { pageSizePointer in
        withUnsafeMutablePointer(to: &totalPages) { totalPagesPointer in
            withUnsafeMutablePointer(to: &availPages) { availPagesPointer in
                mdbx_get_sysraminfo(pageSizePointer, totalPagesPointer, availPagesPointer)
            }
        }
    }
}

/** \brief Returns maximal database size in bytes for given page size,
 * or -1 if pagesize is invalid.
 * \ingroup c_statinfo */

public func maxDatabaseSize(for pageSize: Int) -> Int {
    return mdbx_limits_dbsize_max(pageSize)
}

/** \brief Returns minimal database size in bytes for given page size,
 * or -1 if pagesize is invalid.
 * \ingroup c_statinfo */

public func minDatabaseSize(for pageSize: Int) -> Int {
    return mdbx_limits_dbsize_min(pageSize)
}

/** \brief Returns maximal key size in bytes for given page size
 * and database flags, or -1 if pagesize is invalid.
 * \ingroup c_statinfo
 * \see db_flags */

public func maxKeySize(for pageSize: Int, flags: MDBXDatabaseFlags) -> Int {
    return mdbx_limits_keysize_max(pageSize, flags.MDBX_db_flags_t)
}

/** \brief Returns the maximal database page size in bytes.
 * \ingroup c_statinfo */

public func maxPageSize() -> Int {
    return mdbx_limits_pgsize_max()
}

/** \brief Returns the minimal database page size in bytes.
 * \ingroup c_statinfo */

public func minPageSize() -> Int {
    return mdbx_limits_pgsize_min()
}

/** \brief Returns maximal write transaction size (i.e. limit for summary volume
 * of dirty pages) in bytes for given page size, or -1 if pagesize is invalid.
 * \ingroup c_statinfo */

public func maxTransactionSize(for pageSize: Int) -> Int {
    return mdbx_limits_txnsize_max(pageSize)
}

/** \brief Returns maximal data size in bytes for given page size
 * and database flags, or -1 if pagesize is invalid.
 * \ingroup c_statinfo
 * \see db_flags */

public func maxValueSize(for pageSize: Int, flags: MDBXDatabaseFlags) -> Int {
    return mdbx_limits_valsize_max(pageSize, flags.MDBX_db_flags_t)
}
