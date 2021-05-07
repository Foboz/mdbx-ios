//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/17/21.
//

import Foundation
import libmdbx_ios

internal typealias MDBX_cursor = OpaquePointer

public final class MDBXCursor {
  internal var _cursor: MDBX_cursor!
  
  /** \brief Create a cursor handle but not bind it to transaction nor DBI handle.
   * \ingroup c_cursors
   *
   * An capable of operation cursor is associated with a specific transaction and
   * database. A cursor cannot be used when its database handle is closed. Nor
   * when its transaction has ended, except with \ref mdbx_cursor_bind() and
   * \ref mdbx_cursor_renew().
   * Also it can be discarded with \ref mdbx_cursor_close().
   *
   * A cursor must be closed explicitly always, before or after its transaction
   * ends. It can be reused with \ref mdbx_cursor_bind()
   * or \ref mdbx_cursor_renew() before finally closing it.
   *
   * \note In contrast to LMDB, the MDBX required that any opened cursors can be
   * reused and must be freed explicitly, regardless ones was opened in a
   * read-only or write transaction. The REASON for this is eliminates ambiguity
   * which helps to avoid errors such as: use-after-free, double-free, i.e.
   * memory corruption and segfaults.
   *
   * \param [in] context A pointer to application context to be associated with
   *                     created cursor and could be retrieved by
   *                     \ref mdbx_cursor_get_userctx() until cursor closed.
   *
   * \returns Created cursor handle or NULL in case out of memory. */

  public func create(context: inout Any) throws {
    _cursor = try withUnsafeMutableBytes(of: &context) { contextPointer in
      guard let _cursor = mdbx_cursor_create(contextPointer.baseAddress) else {
        throw MDBXError.ENOMEM
      }
      
      return _cursor
    }
  }
  
  /** \brief Create a cursor handle but not bind it to transaction nor DBI handle.
   * \ingroup c_cursors
   *
   * An capable of operation cursor is associated with a specific transaction and
   * database. A cursor cannot be used when its database handle is closed. Nor
   * when its transaction has ended, except with \ref mdbx_cursor_bind() and
   * \ref mdbx_cursor_renew().
   * Also it can be discarded with \ref mdbx_cursor_close().
   *
   * A cursor must be closed explicitly always, before or after its transaction
   * ends. It can be reused with \ref mdbx_cursor_bind()
   * or \ref mdbx_cursor_renew() before finally closing it.
   *
   * \note In contrast to LMDB, the MDBX required that any opened cursors can be
   * reused and must be freed explicitly, regardless ones was opened in a
   * read-only or write transaction. The REASON for this is eliminates ambiguity
   * which helps to avoid errors such as: use-after-free, double-free, i.e.
   * memory corruption and segfaults.
   *
   * \param [in] context A pointer to application context to be associated with
   *                     created cursor and could be retrieved by
   *                     \ref mdbx_cursor_get_userctx() until cursor closed.
   *
   * \returns Created cursor handle or NULL in case out of memory. */

  public func create() throws {
    _cursor = mdbx_cursor_create(nil)
  }
  
  /** \brief Create a cursor handle for the specified transaction and DBI handle.
   * \ingroup c_cursors
   *
   * Using of the `mdbx_cursor_open()` is equivalent to calling
   * \ref mdbx_cursor_create() and then \ref mdbx_cursor_bind() functions.
   *
   * An capable of operation cursor is associated with a specific transaction and
   * database. A cursor cannot be used when its database handle is closed. Nor
   * when its transaction has ended, except with \ref mdbx_cursor_bind() and
   * \ref mdbx_cursor_renew().
   * Also it can be discarded with \ref mdbx_cursor_close().
   *
   * A cursor must be closed explicitly always, before or after its transaction
   * ends. It can be reused with \ref mdbx_cursor_bind()
   * or \ref mdbx_cursor_renew() before finally closing it.
   *
   * \note In contrast to LMDB, the MDBX required that any opened cursors can be
   * reused and must be freed explicitly, regardless ones was opened in a
   * read-only or write transaction. The REASON for this is eliminates ambiguity
   * which helps to avoid errors such as: use-after-free, double-free, i.e.
   * memory corruption and segfaults.
   *
   * \param [in] txn      A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi      A database handle returned by \ref mdbx_dbi_open().
   * \param [out] cursor  Address where the new \ref MDBX_cursor handle will be
   *                      stored.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_EINVAL  An invalid parameter was specified. */

  public func open(transaction: MDBXTransaction, database: MDBXDatabase) throws {
    let code = mdbx_cursor_open(transaction._txn, database._dbi, &_cursor)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  
  /** \brief Bind cursor to specified transaction and DBI handle.
   * \ingroup c_cursors
   *
   * Using of the `mdbx_cursor_bind()` is equivalent to calling
   * \ref mdbx_cursor_renew() but with specifying an arbitrary dbi handle.
   *
   * An capable of operation cursor is associated with a specific transaction and
   * database. The cursor may be associated with a new transaction,
   * and referencing a new or the same database handle as it was created with.
   * This may be done whether the previous transaction is live or dead.
   *
   * \note In contrast to LMDB, the MDBX required that any opened cursors can be
   * reused and must be freed explicitly, regardless ones was opened in a
   * read-only or write transaction. The REASON for this is eliminates ambiguity
   * which helps to avoid errors such as: use-after-free, double-free, i.e.
   * memory corruption and segfaults.
   *
   * \param [in] txn      A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi      A database handle returned by \ref mdbx_dbi_open().
   * \param [out] cursor  A cursor handle returned by \ref mdbx_cursor_create().
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_EINVAL  An invalid parameter was specified. */

  public func bind(transaction: MDBXTransaction, database: MDBXDatabase) throws {
    
    let code = mdbx_cursor_bind(transaction._txn, _cursor, database._dbi)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  
  /** \brief Copy cursor position and state.
   * \ingroup c_cursors
   *
   * \param [in] src       A source cursor handle returned
   * by \ref mdbx_cursor_create() or \ref mdbx_cursor_open().
   *
   * \param [in,out] dest  A destination cursor handle returned
   * by \ref mdbx_cursor_create() or \ref mdbx_cursor_open().
   *
   * \returns A non-zero error value on failure and 0 on success. */

  public func copy(cursor: MDBXCursor) throws {
    let code = mdbx_cursor_copy(cursor._cursor, _cursor)
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  
  /** \brief Return the cursor's database handle.
   * \ingroup c_cursors
   *
   * \param [in] cursor  A cursor handle returned by \ref mdbx_cursor_open(). */

  public func dbi() -> MDBXDatabase {
    let dbi = mdbx_cursor_dbi(_cursor)
    return MDBXDatabase(dbi: dbi)
  }
  
  /** \brief Determines whether the cursor is pointed to a key-value pair or not,
   * i.e. was not positioned or points to the end of data.
   * \ingroup c_cursors
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   *
   * \returns A \ref MDBX_RESULT_TRUE or \ref MDBX_RESULT_FALSE value,
   *          otherwise the error code:
   * \retval MDBX_RESULT_TRUE    No more data available or cursor not
   *                             positioned
   * \retval MDBX_RESULT_FALSE   A data is available
   * \retval Otherwise the error code */

  public func eof() throws -> Bool {
    let code = mdbx_cursor_eof(_cursor)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return code == MDBX_RESULT_TRUE.rawValue
    }
    throw error
  }
  
  /** \brief Get the application information associated with the MDBX_cursor.
   * \ingroup c_cursors
   * \see mdbx_cursor_set_userctx()
   *
   * \param [in] cursor  An cursor handle returned by \ref mdbx_cursor_create()
   *                     or \ref mdbx_cursor_open().
   * \returns The pointer which was passed via the `context` parameter
   *          of `mdbx_cursor_create()` or set by \ref mdbx_cursor_set_userctx(),
   *          or `NULL` if something wrong. */

  public func unsafeGetContext<T>() -> T? {
    guard let contextPointer = mdbx_cursor_get_userctx(_cursor) else { return nil }
    
    return contextPointer.load(as: T.self)
  }
  
  /** \brief Determines whether the cursor is pointed to the first key-value pair
   * or not. \ingroup c_cursors
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   *
   * \returns A MDBX_RESULT_TRUE or MDBX_RESULT_FALSE value,
   *          otherwise the error code:
   * \retval MDBX_RESULT_TRUE   Cursor positioned to the first key-value pair
   * \retval MDBX_RESULT_FALSE  Cursor NOT positioned to the first key-value
   * pair \retval Otherwise the error code */

  public func onFirst() throws -> Bool {
    let code = mdbx_cursor_on_first(_cursor)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return code == MDBX_RESULT_TRUE.rawValue
    }
    throw error
  }
  
  /** \brief Determines whether the cursor is pointed to the last key-value pair
   * or not. \ingroup c_cursors
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   *
   * \returns A \ref MDBX_RESULT_TRUE or \ref MDBX_RESULT_FALSE value,
   *          otherwise the error code:
   * \retval MDBX_RESULT_TRUE   Cursor positioned to the last key-value pair
   * \retval MDBX_RESULT_FALSE  Cursor NOT positioned to the last key-value pair
   * \retval Otherwise the error code */

  public func onLast() throws -> Bool {
    let code = mdbx_cursor_on_last(_cursor)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return code == MDBX_RESULT_TRUE.rawValue
    }
    throw error
  }
  
  /** \brief Renew a cursor handle.
   * \ingroup c_cursors
   *
   * An capable of operation cursor is associated with a specific transaction and
   * database. The cursor may be associated with a new transaction,
   * and referencing a new or the same database handle as it was created with.
   * This may be done whether the previous transaction is live or dead.
   *
   * Using of the `mdbx_cursor_renew()` is equivalent to calling
   * \ref mdbx_cursor_bind() with the DBI handle that previously
   * the cursor was used with.
   *
   * \note In contrast to LMDB, the MDBX allow any cursor to be re-used by using
   * \ref mdbx_cursor_renew(), to avoid unnecessary malloc/free overhead until it
   * freed by \ref mdbx_cursor_close().
   *
   * \param [in] txn      A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] cursor   A cursor handle returned by \ref mdbx_cursor_open().
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_EINVAL  An invalid parameter was specified. */

  public func renew(transaction: MDBXTransaction) throws {
    let code = mdbx_cursor_renew(transaction._txn, _cursor)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  
  /** \brief Set application information associated with the \ref MDBX_cursor.
   * \ingroup c_cursors
   * \see mdbx_cursor_get_userctx()
   *
   * \param [in] cursor  An cursor handle returned by \ref mdbx_cursor_create()
   *                     or \ref mdbx_cursor_open().
   * \param [in] ctx     An arbitrary pointer for whatever the application needs.
   *
   * \returns A non-zero error value on failure and 0 on success. */
  
  public func unsafeSetContext<T>(_ context: inout T) throws {
    let code = withUnsafeMutableBytes(of: &context, { contextPointer in
      mdbx_cursor_set_userctx(_cursor, contextPointer.baseAddress)
    })
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }
    throw error
  }
  
//  public func transaction() -> MDBXTransaction {
//    let txn = mdbx_cursor_txn(_cursor)
//    let transaction = MDBXTransaction(<#MDBXEnvironment#>)
//    transaction._txn = txn
//    
//    return transaction
//  }

  /** \brief Close a cursor handle.
   * \ingroup c_cursors
   *
   * The cursor handle will be freed and must not be used again after this call,
   * but its transaction may still be live.
   *
   * \note In contrast to LMDB, the MDBX required that any opened cursors can be
   * reused and must be freed explicitly, regardless ones was opened in a
   * read-only or write transaction. The REASON for this is eliminates ambiguity
   * which helps to avoid errors such as: use-after-free, double-free, i.e.
   * memory corruption and segfaults.
   *
   * \param [in] cursor  A cursor handle returned by \ref mdbx_cursor_open()
   *                     or \ref mdbx_cursor_create(). */

  public func close() {
    mdbx_cursor_close(_cursor)
  }
}
