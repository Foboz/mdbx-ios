//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/17/21.
//

import Foundation
import libmdbx_ios

internal typealias MDBX_cursor = OpaquePointer

final class MDBXCursor {
  internal enum MDBXCursorState {
    case unknown
    case created
    case opened
  }
  
  private var _state = MDBXCursorState.unknown
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

  func create(context: inout Any?) throws {
    guard self._state == .unknown else {
      throw MDBXError.alreadyCreated
    }
    
    try withUnsafeMutableBytes(of: &context) { contextPointer in
      guard let _cursor = mdbx_cursor_create(contextPointer.baseAddress) else {
        throw MDBXError.ENOMEM
      }
      
      self._cursor = _cursor
    }
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

  func open(transaction: MDBXTransaction, database: MDBXDatabase) throws {
    guard self._state == .created else {
      if self._state == .unknown {
        throw MDBXError.notCreated
      } else {
        throw MDBXError.alreadyOpened
      }
      
      //mdbx_cursor_open(transaction._txn, database._dbi, <#T##cursor: UnsafeMutablePointer<OpaquePointer?>!##UnsafeMutablePointer<OpaquePointer?>!#>)
    }
  }
  
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

  func close() {
    guard _state == .created || _state == .opened else {
      return
    }
    
    mdbx_cursor_close(_cursor)
    _state = .unknown
  }
}
