//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/15/21.
//

import Foundation
import libmdbx_ios

internal typealias MDBX_dbi = UInt32

public final class MDBXDatabase {
  internal var _dbi: MDBX_dbi = 0
  internal var _env: MDBXEnvironment?
  
  init(dbi: MDBX_dbi) {
    _dbi = dbi
  }
  
  init() {
    
  }
  
  deinit {
    close()
  }
  
  /** \brief Open or Create a database in the environment.
   * \ingroup c_dbi
   *
   * A database handle denotes the name and parameters of a database,
   * independently of whether such a database exists. The database handle may be
   * discarded by calling \ref mdbx_dbi_close(). The old database handle is
   * returned if the database was already open. The handle may only be closed
   * once.
   *
   * \note A notable difference between MDBX and LMDB is that MDBX make handles
   * opened for existing databases immediately available for other transactions,
   * regardless this transaction will be aborted or reset. The REASON for this is
   * to avoiding the requirement for multiple opening a same handles in
   * concurrent read transactions, and tracking of such open but hidden handles
   * until the completion of read transactions which opened them.
   *
   * Nevertheless, the handle for the NEWLY CREATED database will be invisible
   * for other transactions until the this write transaction is successfully
   * committed. If the write transaction is aborted the handle will be closed
   * automatically. After a successful commit the such handle will reside in the
   * shared environment, and may be used by other transactions.
   *
   * In contrast to LMDB, the MDBX allow this function to be called from multiple
   * concurrent transactions or threads in the same process.
   *
   * To use named database (with name != NULL), \ref mdbx_env_set_maxdbs()
   * must be called before opening the environment. Table names are
   * keys in the internal unnamed database, and may be read but not written.
   *
   * \param [in] txn    transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] name   The name of the database to open. If only a single
   *                    database is needed in the environment,
   *                    this value may be NULL.
   * \param [in] flags  Special options for this database. This parameter must
   *                    be set to 0 or by bitwise OR'ing together one or more
   *                    of the values described here:
   *  - \ref MDBX_REVERSEKEY
   *      Keys are strings to be compared in reverse order, from the end
   *      of the strings to the beginning. By default, Keys are treated as
   *      strings and compared from beginning to end.
   *  - \ref MDBX_INTEGERKEY
   *      Keys are binary integers in native byte order, either uint32_t or
   *      uint64_t, and will be sorted as such. The keys must all be of the
   *      same size and must be aligned while passing as arguments.
   *  - \ref MDBX_DUPSORT
   *      Duplicate keys may be used in the database. Or, from another point of
   *      view, keys may have multiple data items, stored in sorted order. By
   *      default keys must be unique and may have only a single data item.
   *  - \ref MDBX_DUPFIXED
   *      This flag may only be used in combination with \ref MDBX_DUPSORT. This
   *      option tells the library that the data items for this database are
   *      all the same size, which allows further optimizations in storage and
   *      retrieval. When all data items are the same size, the
   *      \ref MDBX_GET_MULTIPLE, \ref MDBX_NEXT_MULTIPLE and
   *      \ref MDBX_PREV_MULTIPLE cursor operations may be used to retrieve
   *      multiple items at once.
   *  - \ref MDBX_INTEGERDUP
   *      This option specifies that duplicate data items are binary integers,
   *      similar to \ref MDBX_INTEGERKEY keys. The data values must all be of the
   *      same size and must be aligned while passing as arguments.
   *  - \ref MDBX_REVERSEDUP
   *      This option specifies that duplicate data items should be compared as
   *      strings in reverse order (the comparison is performed in the direction
   *      from the last byte to the first).
   *  - \ref MDBX_CREATE
   *      Create the named database if it doesn't exist. This option is not
   *      allowed in a read-only transaction or a read-only environment.
   *
   * \param [out] dbi     Address where the new \ref MDBX_dbi handle
   *                      will be stored.
   *
   * For \ref mdbx_dbi_open_ex() additional arguments allow you to set custom
   * comparison functions for keys and values (for multimaps).
   * However, I recommend not using custom comparison functions, but instead
   * converting the keys to one of the forms that are suitable for built-in
   * comparators (for instance take look to the \ref value2key).
   * The reasons to not using custom comparators are:
   *   - The order of records could not be validated without your code.
   *     So `mdbx_chk` utility will reports "wrong order" errors
   *     and the `-i` option is required to ignore ones.
   *   - A records could not be ordered or sorted without your code.
   *     So mdbx_load utility should be used with `-a` option to preserve
   *     input data order.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_NOTFOUND   The specified database doesn't exist in the
   *                         environment and \ref MDBX_CREATE was not specified.
   * \retval MDBX_DBS_FULL   Too many databases have been opened.
   *                         \see mdbx_env_set_maxdbs()
   * \retval MDBX_INCOMPATIBLE  Database is incompatible with given flags,
   *                         i.e. the passed flags is different with which the
   *                         database was created, or the database was already
   *                         opened with a different comparison function(s).
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread. */

  public func open(
    transaction: MDBXTransaction,
    name: String?,
    flags: MDBXDatabaseFlags
  ) throws {
    let code = withUnsafeMutablePointer(to: &_dbi) { pointer in
      return mdbx_dbi_open(
        transaction._txn,
        name,
        flags.MDBX_db_flags_t,
        pointer
      )
    }
    guard code != 0, let error = MDBXError(code: code) else {
      _env = transaction.environment
      return
    }
    throw error
  }
  
  /** \brief Close a database handle. Normally unnecessary.
   * \ingroup c_dbi
   *
   * Closing a database handle is not necessary, but lets \ref mdbx_dbi_open()
   * reuse the handle value. Usually it's better to set a bigger
   * \ref mdbx_env_set_maxdbs(), unless that value would be large.
   *
   * \note Use with care.
   * This call is synchronized via mutex with \ref mdbx_dbi_close(), but NOT with
   * other transactions running by other threads. The "next" version of libmdbx
   * (\ref MithrilDB) will solve this issue.
   *
   * Handles should only be closed if no other threads are going to reference
   * the database handle or one of its cursors any further. Do not close a handle
   * if an existing transaction has modified its database. Doing so can cause
   * misbehavior from database corruption to errors like \ref MDBX_BAD_DBI
   * (since the DB name is gone).
   *
   * \param [in] env  An environment handle returned by \ref mdbx_env_create().
   * \param [in] dbi  A database handle returned by \ref mdbx_dbi_open().
   *
   * \returns A non-zero error value on failure and 0 on success. */

  public func close() {
    guard let env = _env else {
      return
    }
    mdbx_dbi_close(env._env, _dbi)
    _env = nil
  }
}
