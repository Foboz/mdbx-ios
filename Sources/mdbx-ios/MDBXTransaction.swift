//
//  MDBXTransaction.swift
//  mdbx-ios
//
//  Created by Mikhail Nikanorov on 4/14/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

/**
 * Opaque structure for a transaction handle.
 *
 * All database operations require a transaction handle. Transactions may be read-only or read-write.
 *
 * # Reference
 *   - \see mdbx_txn_begin()
 *   - \see mdbx_txn_commit()
 *   - \see mdbx_txn_abort()
 *
 * - Tag: MDBX_txn
 */
internal typealias MDBX_txn = OpaquePointer

public final class MDBXTransaction {
  internal var _txn: MDBX_txn!
  
  /**
   * Returns the transaction's MDBX_env.
   */
  public let environment: MDBXEnvironment
  
  /**
   * Return the transaction's flags.
   *
   * This returns the flags associated with this transaction.
   *
   * # Returns:
   *   A transaction flags, valid if input is an valid transaction, otherwise -1.
   */
  public var flags: MDBXTransactionFlags {
    let flags = mdbx_txn_flags(self._txn)
    return MDBXTransactionFlags(rawValue: UInt32(flags))
  }
  
  /**
   * Return the transaction's ID.
   *
   * This returns the identifier associated with this transaction. For a read-only transaction, this corresponds to the snapshot being read;
   * concurrent readers will frequently have the same transaction ID.
   *
   * # Returns:
   *   A transaction ID, valid if input is an active transaction, otherwise 0.
   */
  public var transactionId: UInt64 {
    return mdbx_txn_id(self._txn)
  }
  
  /**
   * Swift-level of get/Set the application information associated with the MDBXTransaction.
   * /see unsafeSetContext(), /see unsafeGetContext()
   */
  public var context: Any?
  
  /**
   * - Parameters:
   *    - environment:
   *      An environment handle returned by \ref mdbx_env_create().
   */
  public init(_ environment: MDBXEnvironment) {
    self.environment = environment
  }
  
  /**
   * - Parameters:
   *   - cursor:
   *     Cursor to transaction handler
   * - Throws:
   *    - badTransaction:
   *      Invalid transction
   */
  internal init(_ cursor: MDBXCursor) throws {
    var txn: MDBX_txn!
    withUnsafeMutablePointer(to: &txn) { pointer in
      pointer.pointee = mdbx_cursor_txn(cursor._cursor)
    }
    self._txn = txn
    guard txn != nil else {
      throw MDBXError.badTransaction
    }
    
    var env: MDBX_env!
    withUnsafeMutablePointer(to: &env) { pointer in
      pointer.pointee = mdbx_txn_env(txn)
    }
    self.environment = MDBXEnvironment(env)
  }
  
  /**
   * Create a transaction with a user provided context pointer for use with the environment.
   *
   * The transaction handle may be discarded using \ref mdbx_txn_abort() or \ref mdbx_txn_commit().
   * \see mdbx_txn_begin()
   *
   * # Note:
   * A transaction and its cursors must only be used by a single thread, and a thread may only have a single transaction at a time. If \ref MDBX_NOTLS
   * is in use, this does not apply to read-only transactions.
   *
   * # Note:
   * Cursors may not span transactions.
   *
   * - Parameters:
   *    - parent
   *    If this parameter is non-NULL, the new transaction will be a nested transaction, with the transaction indicated
   *    by parent as its parent. Transactions may be nested to any level. A parent transaction and its cursors may
   *    not issue any other operations than mdbx_txn_commit and \ref mdbx_txn_abort() while it has active child
   *    transactions.
   *
   *    - flags
   *    Special options for this transaction. This parameter must be set to 0 or by bitwise OR'ing together one
   *    or more of the values described here:
   *      - MDBX_RDONLY
   *        This transaction will not perform any write operations.
   *
   *      - MDBX_TXN_TRY
   *        Do not block when starting a write transaction.
   *
   *      - MDBX_SAFE_NOSYNC, MDBX_NOMETASYNC.
   *        Do not sync data to disk corresponding to \ref MDBX_NOMETASYNC or \ref MDBX_SAFE_NOSYNC description.
   *        \see sync_modes
   *
   *    - context:
   *      A pointer to application context to be associated with created transaction and could be retrieved by
   *      \ref mdbx_txn_get_userctx() until transaction finished.
   *
   * - Throws:
   *    - MDBX_PANIC:
   *      A fatal error occurred earlier and the environment must be shut down.
   *    - MDBX_UNABLE_EXTEND_MAPSIZE:
   *      Another process wrote data beyond this MDBX_env's mapsize and this environment map must be resized as well.
   *      See \ref mdbx_env_set_mapsize().
   *    - MDBX_READERS_FULL:
   *      A read-only transaction was requested and the reader lock table is full.
   *      See \ref mdbx_env_set_maxreaders().
   *    - MDBX_ENOMEM:
   *      Out of memory.
   *    - MDBX_BUSY:
   *      The write transaction is already started by the current thread.
   */
  public func begin(parent: MDBXTransaction? = nil, flags: MDBXTransactionFlags, context: inout Any) throws {
    let code = withUnsafeMutablePointer(to: &self._txn) { pointer -> Int32 in
      return withUnsafeMutableBytes(of: &context, { contextPointer in
        return mdbx_txn_begin_ex(self.environment._env,
                                 parent?._txn,
                                 flags.MDBX_txn_flags_t,
                                 pointer,
                                 contextPointer.baseAddress)
      })
    }
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Create a transaction for use with the environment.
   * \ingroup c_transactions
   *
   * The transaction handle may be discarded using \ref mdbx_txn_abort()
   * or \ref mdbx_txn_commit().
   * \see mdbx_txn_begin_ex()
   *
   * \note A transaction and its cursors must only be used by a single thread,
   * and a thread may only have a single transaction at a time. If \ref MDBX_NOTLS
   * is in use, this does not apply to read-only transactions.
   *
   * \note Cursors may not span transactions.
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create().
   *
   * \param [in] parent  If this parameter is non-NULL, the new transaction will
   *                     be a nested transaction, with the transaction indicated
   *                     by parent as its parent. Transactions may be nested
   *                     to any level. A parent transaction and its cursors may
   *                     not issue any other operations than mdbx_txn_commit and
   *                     \ref mdbx_txn_abort() while it has active child
   *                     transactions.
   *
   * \param [in] flags   Special options for this transaction. This parameter
   *                     must be set to 0 or by bitwise OR'ing together one
   *                     or more of the values described here:
   *                      - \ref MDBX_RDONLY   This transaction will not perform
   *                                           any write operations.
   *
   *                      - \ref MDBX_TXN_TRY  Do not block when starting
   *                                           a write transaction.
   *
   *                      - \ref MDBX_SAFE_NOSYNC, \ref MDBX_NOMETASYNC.
   *                        Do not sync data to disk corresponding
   *                        to \ref MDBX_NOMETASYNC or \ref MDBX_SAFE_NOSYNC
   *                        description. \see sync_modes
   *
   * \param [out] txn    Address where the new MDBX_txn handle will be stored.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_PANIC         A fatal error occurred earlier and the
   *                            environment must be shut down.
   * \retval MDBX_UNABLE_EXTEND_MAPSIZE  Another process wrote data beyond
   *                                     this MDBX_env's mapsize and this
   *                                     environment map must be resized as well.
   *                                     See \ref mdbx_env_set_mapsize().
   * \retval MDBX_READERS_FULL  A read-only transaction was requested and
   *                            the reader lock table is full.
   *                            See \ref mdbx_env_set_maxreaders().
   * \retval MDBX_ENOMEM        Out of memory.
   * \retval MDBX_BUSY          The write transaction is already started by the
   *                            current thread.
   */
  public func begin(parent: MDBXTransaction? = nil, flags: MDBXTransactionFlags) throws {
    let code = withUnsafeMutablePointer(to: &self._txn) { pointer -> Int32 in
      return mdbx_txn_begin(self.environment._env,
                            parent?._txn,
                            flags.MDBX_txn_flags_t,
                            pointer)
    }
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Get the application information associated with the MDBX_txn.
   * \see mdbx_txn_set_userctx()
   *
   * # Returns:
   *   The pointer which was passed via the `context` parameter of `mdbx_txn_begin_ex()` or set by \ref mdbx_txn_set_userctx(),
   *   or `NULL` if something wrong.
   */
  public func unsafeGetContext<T>() -> T? {
    guard let contextPointer = mdbx_txn_get_userctx(self._txn) else { return nil }
    
    return contextPointer.load(as: T.self)
  }
  
  /**
   * Set application information associated with the \ref MDBX_txn.
   * \see mdbx_txn_get_userctx()
   *
   * - Parameters:
   *   - context:
   *     An arbitrary pointer for whatever the application needs.
   */
  public func unsafeSetContext<T>(_ context: inout T) throws {
    let code = withUnsafeMutableBytes(of: &context, { contextPointer in
      mdbx_txn_set_userctx(self._txn, contextPointer.baseAddress)
    })
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  
  /**
   * Resets mdbx transaction context
   */
  public func unsafeResetContext() throws {
    let code = mdbx_txn_set_userctx(self._txn, nil)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Marks transaction as broken.
   *
   * public function keeps the transaction handle and corresponding locks, but it is not possible to perform any operations in a broken transaction.
   * Broken transaction must then be aborted explicitly later.
   *
   * \see mdbx_txn_abort() \see mdbx_txn_reset() \see mdbx_txn_commit()
   * \returns A non-zero error value on failure and 0 on success.
   */
  public func `break`() throws {
    let code = mdbx_txn_break(self._txn)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Commit all the operations of a transaction into the database.
   *
   * If the current thread is not eligible to manage the transaction then the \ref MDBX_THREAD_MISMATCH error will returned. Otherwise the transaction
   * will be committed and its handle is freed. If the transaction cannot be committed, it will be aborted with the corresponding error returned.
   *
   * Thus, a result other than \ref MDBX_THREAD_MISMATCH means that the transaction is terminated:
   *  - Resources are released;
   *  - Transaction handle is invalid;
   *  - Cursor(s) associated with transaction must not be used, except with
   *    mdbx_cursor_renew() and \ref mdbx_cursor_close().
   *    Such cursor(s) must be closed explicitly by \ref mdbx_cursor_close()
   *    before or after transaction commit, either can be reused with
   *    \ref mdbx_cursor_renew() until it will be explicitly closed by
   *    \ref mdbx_cursor_close().
   *
   * - Throws:
   *   - MDBX_RESULT_TRUE:
   *     Transaction was aborted since it should be aborted due to previous errors.
   *   - MDBX_PANIC:
   *     A fatal error occurred earlier and the environment must be shut down.
   *   - MDBX_BAD_TXN:
   *     Transaction is already finished or never began.
   *   - MDBX_EBADSIGN;
   *     Transaction object has invalid signature, e.g. transaction was already terminated
   *     or memory was corrupted.
   *   - MDBX_THREAD_MISMATCH:
   *     Given transaction is not owned by current thread.
   *   - MDBX_EINVAL:
   *     Transaction handle is NULL.
   *   - MDBX_ENOSPC:
   *     No more disk space.
   *   - MDBX_EIO:
   *     A system-level I/O error occurred.
   *   - MDBX_ENOMEM:
   *     Out of memory.
   */
  public func commit() throws {
    let code = mdbx_txn_commit(self._txn)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Reset a read-only transaction.
   *
   * Abort the read-only transaction like \ref mdbx_txn_abort(), but keep the transaction handle. Therefore \ref mdbx_txn_renew() may reuse the handle.
   * This saves allocation overhead if the process will start a new read-only transaction soon, and also locking overhead if \ref MDBX_NOTLS is in use. The
   * reader table lock is released, but the table slot stays tied to its thread or \ref MDBX_txn. Use \ref mdbx_txn_abort() to discard a reset handle, and to
   * free its lock table slot if \ref MDBX_NOTLS is in use.
   *
   * Cursors opened within the transaction must not be used again after this call, except with \ref mdbx_cursor_renew() and \ref mdbx_cursor_close().
   *
   * Reader locks generally don't interfere with writers, but they keep old versions of database pages allocated. Thus they prevent the old pages from
   * being reused when writers commit new data, and so under heavy load the database size may grow much more rapidly than otherwise.
   *
   * - Throws:
   *   - MDBX_PANIC:
   *     A fatal error occurred earlier and the environment must be shut down.
   *   - MDBX_BAD_TXN:
   *     Transaction is already finished or never began.
   *   - MDBX_EBADSIGN:
   *     Transaction object has invalid signature, e.g. transaction was already terminated
   *     or memory was corrupted.
   *   - MDBX_THREAD_MISMATCH:
   *     Given transaction is not owned by current thread.
   *   - MDBX_EINVAL:
   *     Transaction handle is NULL.
   */
  public func reset() throws {
    let code = mdbx_txn_reset(self._txn)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Renew a read-only transaction.
   *
   * This acquires a new reader lock for a transaction handle that had been released by \ref mdbx_txn_reset(). It must be called before a reset
   * transaction may be used again.
   *
   * - Throws:
   * - MDBX_PANIC:
   *   A fatal error occurred earlier and the environment must be shut down.
   * - MDBX_BAD_TXN:
   *   Transaction is already finished or never began.
   * - MDBX_EBADSIGN:
   *   Transaction object has invalid signature, e.g. transaction was already terminated
   *   or memory was corrupted.
   * - MDBX_THREAD_MISMATCH:
   *   Given transaction is not owned by current thread.
   * - MDBX_EINVAL:
   *   Transaction handle is NULL.
   */
  public func renew() throws {
    let code = mdbx_txn_renew(self._txn)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Abandon all the operations of the transaction instead of saving them.
   *
   * The transaction handle is freed. It and its cursors must not be used again after this call, except with \ref mdbx_cursor_renew() and
   * \ref mdbx_cursor_close().
   *
   * If the current thread is not eligible to manage the transaction then the \ref MDBX_THREAD_MISMATCH error will returned. Otherwise the transaction
   * will be aborted and its handle is freed. Thus, a result other than \ref MDBX_THREAD_MISMATCH means that the transaction is terminated:
   *  - Resources are released;
   *  - Transaction handle is invalid;
   *  - Cursor(s) associated with transaction must not be used, except with
   *    \ref mdbx_cursor_renew() and \ref mdbx_cursor_close().
   *    Such cursor(s) must be closed explicitly by \ref mdbx_cursor_close()
   *    before or after transaction abort, either can be reused with
   *    \ref mdbx_cursor_renew() until it will be explicitly closed by
   *    \ref mdbx_cursor_close().
   *
   * - Throws:
   *   - MDBX_PANIC:
   *     A fatal error occurred earlier and the environment must be shut down.
   *   - MDBX_BAD_TXN:
   *     Transaction is already finished or never began.
   *   - MDBX_EBADSIGN:
   *     Transaction object has invalid signature, e.g. transaction was already terminated
   *     or memory was corrupted.
   *   - MDBX_THREAD_MISMATCH:
   *     Given transaction is not owned by current thread.
   *   - MDBX_EINVAL
   *     Transaction handle is NULL.
   */
  public func abort() throws {
    let code = mdbx_txn_abort(self._txn)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
}
