//
//  MDBXEnvironment.swift
//  mdbx-ios
//
//  Created by Mikhail Nikanorov on 4/7/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

/**
 * Opaque structure for a database environment.
 *
 * An environment supports multiple key-value sub-databases (aka key-value spaces or tables), all residing in the same shared-memory map.
 *
 * # Reference
 *    - [create()](x-source-tag://[MDBXEnvironment.create])
 *    - [close()](x-source-tag://[MDBXEnvironment.close])
 *
 * - Tag: MDBX_env
 */
internal typealias MDBX_env = OpaquePointer


public typealias MDBXEnvironmentHandleSlowRead = (_ environment: MDBXEnvironment?, _ transaction: MDBXTransaction?, _ processId: pid_t, _ threadId: pthread_t?, _ laggard: UInt64, _ gap: UInt32, _ space: Int, _ retry: Int32) -> Int32

public class MDBXEnvironment {
  internal enum MDBXEnvironmentState {
    case unknown
    case created
    case opened
  }
  
  internal var _env: MDBX_env!
  internal var _state: MDBXEnvironmentState = .unknown
  
  public init() {}
  
  deinit {
    if _state == .opened {
      self.close()
    }
  }
  
  /**
   * Create an MDBX environment instance.
   *
   * This function allocates memory for a [MDBX_env](x-source-tag://[MDBX_env]) structure. To release
   * the allocated memory and discard the handle, call [close()](x-source-tag://[MDBXEnvironment.close]).
   * Before the handle may be used, it must be opened using [open()](x-source-tag://[MDBXEnvironment.open]).
   *
   * Various other options may also need to be set before opening the handle,
   * e.g. \ref mdbx_env_set_geometry(), \ref mdbx_env_set_maxreaders(),
   * \ref mdbx_env_set_maxdbs(), depending on usage requirements.
   *
   * - Throws:
   *    - [alreadyCreated](x-source-tag://[MDBXError.alreadyCreated]):
   *      If environment already opened
   *
   * - Tag: MDBXEnvironment.create
   */

  public func create() throws {
    guard self._state == .unknown else { throw MDBXError.alreadyCreated }
    let code = withUnsafeMutablePointer(to: &_env) { pointer in
      return mdbx_env_create(pointer)
    }
    guard code != 0, let error = MDBXError(code: code) else {
      self._state = .created
      return
    }
    throw error
  }
  
  /**
   * Open an environment instance.
   *
   * Indifferently this function will fails or not, the [close()](x-source-tag://[MDBXEnvironment.close]) must
   * be called later to discard the [MDBX_env](x-source-tag://[MDBX_env]) handle and release associated
   * resources.
   *
   * - Flags set by mdbx_env_set_flags() are also used:
   *    - [noSubDir](x-source-tag://[MDBXEnvironmentFlags.noSubDir])
   *    - [readOnly](x-source-tag://[MDBXEnvironmentFlags.readOnly])
   *    - [exclusive](x-source-tag://[MDBXEnvironmentFlags.exclusive])
   *    - [writeMap](x-source-tag://[MDBXEnvironmentFlags.writeMap])
   *    - [noTLS](x-source-tag://[MDBXEnvironmentFlags.noTLS])
   *    - [noReadAhead](x-source-tag://[MDBXEnvironmentFlags.noReadAhead])
   *    - [noMemoryInit](x-source-tag://[MDBXEnvironmentFlags.noMemoryInit])
   *    - [coalesce](x-source-tag://[MDBXEnvironmentFlags.coalesce])
   *    - [lifoReclaim](x-source-tag://[MDBXEnvironmentFlags.lifoReclaim])
   *    - [noMetaSync](x-source-tag://[MDBXEnvironmentFlags.noMetaSync])
   *    - [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync])
   *    - [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync])
   *
   *    # Reference
   *    - [flags](x-source-tag://[MDBXEnvironmentFlags])
   *    - [syncModes](x-source-tag://[MDBXEnvironmentFlags.SyncModes])
   *
   * # Note:
   *  `MDB_NOLOCK` flag don't supported by MDBX, try use \ref MDBX_EXCLUSIVE as a replacement.
   *
   * # Note:
   * MDBX don't allow to mix processes with different \ref MDBX_SAFE_NOSYNC flags on the same environment.
   * In such case \ref MDBX_INCOMPATIBLE will be returned.
   *
   * If the database is already exist and parameters specified early by \ref mdbx_env_set_geometry() are incompatible (i.e. for instance, different
   * page size) then \ref mdbx_env_open() will return \ref MDBX_INCOMPATIBLE error.
   *
   * - Parameters:
   *    - pathname:
   *      The pathname for the database or the directory in which
   *      the database files reside. In the case of directory it
   *      must already exist and be writable.
   *
   *    - flags:
   *      Special options for this environment. This parameter
   *      must be set to 0 or by bitwise OR'ing together one
   *      or more of the values described above in the
   *      \ref env_flags and \ref sync_modes sections.
   *
   *    - mode:
   *      The UNIX permissions to set on created files.
   *      Zero value means to open existing, but do not create.
   *
   * - Throws:
   *    - MDBX_VERSION_MISMATCH:
   *      The version of the MDBX library doesn't match the version that created the database environment.
   *    - MDBX_INVALID:
   *      The environment file headers are corrupted.
   *    - MDBX_ENOENT:
   *      The directory specified by the path parameter doesn't exist.
   *    - MDBX_EACCES:
   *      The user didn't have permission to access the environment files.
   *    - MDBX_EAGAIN:
   *      The environment was locked by another process.
   *    - MDBX_BUSY:
   *      The \ref MDBX_EXCLUSIVE flag was specified and the environment is in use by another process,
   *      or the current process tries to open environment more than once.
   *    - MDBX_INCOMPATIBLE:
   *      Environment is already opened by another process, but with different set of \ref MDBX_SAFE_NOSYNC,
   *      \ref MDBX_UTTERLY_NOSYNC flags. Or if the database is already exist and parameters
   *      specified early by \ref mdbx_env_set_geometry() are incompatible (i.e. different pagesize, etc).
   *    - MDBX_WANNA_RECOVERY:
   *      The \ref MDBX_RDONLY flag was specified but read-write access is required to rollback
   *      inconsistent state after a system crash.
   *    - MDBX_TOO_LARGE:
   *      Database is too large for this process, i.e. 32-bit process tries to open >4Gb database.
   *
   * - Tag: MDBXEnvironment.open
   */
  public func open(path: String, flags: MDBXEnvironmentFlags, mode: MDBXEnvironmentMode) throws {
    guard self._state == .created else {
      if self._state == .unknown { throw MDBXError.notCreated }
      else { throw MDBXError.alreadyOpened }
    }
    let code = mdbx_env_open(_env, path.cString(using: .utf8), flags.MDBX_env_flags_t, mode.rawValue)
    self._state = .opened
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   * Close the environment and release the memory map.
   *
   * Only a single thread may call this function. All transactions, databases, and cursors must already be closed before calling this function. Attempts
   * to use any such handles after calling this function will cause a `SIGSEGV`. The environment handle will be freed and must not be used again after this
   * call.
   *
   * - Parameters:
   *    - dontSync:
   *      A dont'sync flag, if non-zero the last checkpoint will be kept "as is" and may be still "weak" in the
   *      [safeNoSync](x-source-tag://[MDBXEnvironmentFlags.safeNoSync]) or [utterlyNoSync](x-source-tag://[MDBXEnvironmentFlags.utterlyNoSync]) modes.
   *      Such "weak" checkpoint will be ignored on opening next time, and transactions since the last non-weak checkpoint (meta-page update) will rolledback
   *      for consistency guarantee.
   *
   * - Throws:
   *    - MDBX_BUSY
   *      The write transaction is running by other thread, in such case \ref MDBX_env instance has NOT be destroyed
   *      not released!
   *      # Note: If any OTHER error code was returned then given MDBX_env instance has been destroyed and released.
   *
   *    - MDBX_EBADSIGN:  Environment handle already closed or not valid,
   *      i.e. \ref mdbx_env_close() was already called for the `env` or was not created by \ref mdbx_env_create().
   *
   *    - MDBX_PANIC:
   *      If \ref mdbx_env_close_ex() was called in the child process after `fork()`. In this case \ref MDBX_PANIC
   *      is expected, i.e. \ref MDBX_env instance was freed in proper manner.
   *
   *    - MDBX_EIO:
   *      An error occurred during synchronization.
   *
   * - Tag: MDBXEnvironment.close
   */
  public func close(_ dontSync: Bool = false) {
    guard self._state == .opened else {
      return
    }
    mdbx_env_close_ex(_env, dontSync)
    self._state = .unknown
  }
  
  /**
   * Get the application information associated with the MDBX_env.
   * \see mdbx_env_set_userctx()
   *
   * \param [in] env An environment handle returned by \ref mdbx_env_create()
   * \returns The pointer set by \ref mdbx_env_set_userctx() or `NULL` if something wrong.
   */

  public func unsafeGetContext<T>() -> T? {
    guard self._state != .unknown else { return nil }
    
    guard let contextPointer = mdbx_env_get_userctx(self._env) else { return nil }
    
    return contextPointer.load(as: T.self)
  }
  
  /**
   * Set application information associated with the \ref MDBX_env.
   * \ingroup c_settings
   * \see mdbx_env_get_userctx()
   *
   * \param [in] env  An environment handle returned by \ref mdbx_env_create().
   * \param [in] ctx  An arbitrary pointer for whatever the application needs.
   *
   * \returns A non-zero error value on failure and 0 on success.
   */
  public func unsafeSetContext<T>(_ context: inout T) throws {
    guard self._state != .unknown else { return }
    
    let code = withUnsafeMutableBytes(of: &context, { contextPointer in
      return mdbx_env_set_userctx(self._env, contextPointer.baseAddress)
    })
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Set the maximum number of threads/reader slots for for all processes
   * interacts with the database. \ingroup c_settings
   *
   * \details This defines the number of slots in the lock table that is used to
   * track readers in the the environment. The default is about 100 for 4K system
   * page size. Starting a read-only transaction normally ties a lock table slot
   * to the current thread until the environment closes or the thread exits. If
   * \ref MDBX_NOTLS is in use, \ref mdbx_txn_begin() instead ties the slot to the
   * \ref MDBX_txn object until it or the \ref MDBX_env object is destroyed.
   * This function may only be called after \ref mdbx_env_create() and before
   * \ref mdbx_env_open(), and has an effect only when the database is opened by
   * the first process interacts with the database.
   * \see mdbx_env_get_maxreaders()
   *
   * \param [in] env       An environment handle returned
   *                       by \ref mdbx_env_create().
   * \param [in] readers   The maximum number of reader lock table slots.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL   An invalid parameter was specified.
   * \retval MDBX_EPERM    The environment is already open. */
  public func setMaxReader(_ reader: UInt32) throws {
    let code = mdbx_env_set_maxreaders(self._env, reader)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Set the maximum number of named databases for the environment.
   * \ingroup c_settings
   *
   * This function is only needed if multiple databases will be used in the
   * environment. Simpler applications that use the environment as a single
   * unnamed database can ignore this option.
   * This function may only be called after \ref mdbx_env_create() and before
   * \ref mdbx_env_open().
   *
   * Currently a moderate number of slots are cheap but a huge number gets
   * expensive: 7-120 words per transaction, and every \ref mdbx_dbi_open()
   * does a linear search of the opened slots.
   * \see mdbx_env_get_maxdbs()
   *
   * \param [in] env   An environment handle returned by \ref mdbx_env_create().
   * \param [in] dbs   The maximum number of databases.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL   An invalid parameter was specified.
   * \retval MDBX_EPERM    The environment is already open. */
  public func setMaxDatabases(_ dbs: UInt32) throws {
    let code = mdbx_env_set_maxdbs(self._env, dbs)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }

  /** \brief Set all size-related parameters of environment, including page size
   * and the min/max size of the memory map. \ingroup c_settings
   *
   * In contrast to LMDB, the MDBX provide automatic size management of an
   * database according the given parameters, including shrinking and resizing
   * on the fly. From user point of view all of these just working. Nevertheless,
   * it is reasonable to know some details in order to make optimal decisions
   * when choosing parameters.
   *
   * Both \ref mdbx_env_info_ex() and legacy \ref mdbx_env_info() are inapplicable
   * to read-only opened environment.
   *
   * Both \ref mdbx_env_info_ex() and legacy \ref mdbx_env_info() could be called
   * either before or after \ref mdbx_env_open(), either within the write
   * transaction running by current thread or not:
   *
   *  - In case \ref mdbx_env_info_ex() or legacy \ref mdbx_env_info() was called
   *    BEFORE \ref mdbx_env_open(), i.e. for closed environment, then the
   *    specified parameters will be used for new database creation, or will be
   *    applied during opening if database exists and no other process using it.
   *
   *    If the database is already exist, opened with \ref MDBX_EXCLUSIVE or not
   *    used by any other process, and parameters specified by
   *    \ref mdbx_env_set_geometry() are incompatible (i.e. for instance,
   *    different page size) then \ref mdbx_env_open() will return
   *    \ref MDBX_INCOMPATIBLE error.
   *
   *    In another way, if database will opened read-only or will used by other
   *    process during calling \ref mdbx_env_open() that specified parameters will
   *    silently discarded (open the database with \ref MDBX_EXCLUSIVE flag
   *    to avoid this).
   *
   *  - In case \ref mdbx_env_info_ex() or legacy \ref mdbx_env_info() was called
   *    after \ref mdbx_env_open() WITHIN the write transaction running by current
   *    thread, then specified parameters will be applied as a part of write
   *    transaction, i.e. will not be visible to any others processes until the
   *    current write transaction has been committed by the current process.
   *    However, if transaction will be aborted, then the database file will be
   *    reverted to the previous size not immediately, but when a next transaction
   *    will be committed or when the database will be opened next time.
   *
   *  - In case \ref mdbx_env_info_ex() or legacy \ref mdbx_env_info() was called
   *    after \ref mdbx_env_open() but OUTSIDE a write transaction, then MDBX will
   *    execute internal pseudo-transaction to apply new parameters (but only if
   *    anything has been changed), and changes be visible to any others processes
   *    immediately after succesful completion of function.
   *
   * Essentially a concept of "automatic size management" is simple and useful:
   *  - There are the lower and upper bound of the database file size;
   *  - There is the growth step by which the database file will be increased,
   *    in case of lack of space.
   *  - There is the threshold for unused space, beyond which the database file
   *    will be shrunk.
   *  - The size of the memory map is also the maximum size of the database.
   *  - MDBX will automatically manage both the size of the database and the size
   *    of memory map, according to the given parameters.
   *
   * So, there some considerations about choosing these parameters:
   *  - The lower bound allows you to prevent database shrinking below some
   *    rational size to avoid unnecessary resizing costs.
   *  - The upper bound allows you to prevent database growth above some rational
   *    size. Besides, the upper bound defines the linear address space
   *    reservation in each process that opens the database. Therefore changing
   *    the upper bound is costly and may be required reopening environment in
   *    case of \ref MDBX_UNABLE_EXTEND_MAPSIZE errors, and so on. Therefore, this
   *    value should be chosen reasonable as large as possible, to accommodate
   *    future growth of the database.
   *  - The growth step must be greater than zero to allow the database to grow,
   *    but also reasonable not too small, since increasing the size by little
   *    steps will result a large overhead.
   *  - The shrink threshold must be greater than zero to allow the database
   *    to shrink but also reasonable not too small (to avoid extra overhead) and
   *    not less than growth step to avoid up-and-down flouncing.
   *  - The current size (i.e. size_now argument) is an auxiliary parameter for
   *    simulation legacy \ref mdbx_env_set_mapsize() and as workaround Windows
   *    issues (see below).
   *
   * Unfortunately, Windows has is a several issues
   * with resizing of memory-mapped file:
   *  - Windows unable shrinking a memory-mapped file (i.e memory-mapped section)
   *    in any way except unmapping file entirely and then map again. Moreover,
   *    it is impossible in any way if a memory-mapped file is used more than
   *    one process.
   *  - Windows does not provide the usual API to augment a memory-mapped file
   *    (that is, a memory-mapped partition), but only by using "Native API"
   *    in an undocumented way.
   *
   * MDBX bypasses all Windows issues, but at a cost:
   *  - Ability to resize database on the fly requires an additional lock
   *    and release `SlimReadWriteLock during` each read-only transaction.
   *  - During resize all in-process threads should be paused and then resumed.
   *  - Shrinking of database file is performed only when it used by single
   *    process, i.e. when a database closes by the last process or opened
   *    by the first.
   *  = Therefore, the size_now argument may be useful to set database size
   *    by the first process which open a database, and thus avoid expensive
   *    remapping further.
   *
   * For create a new database with particular parameters, including the page
   * size, \ref mdbx_env_set_geometry() should be called after
   * \ref mdbx_env_create() and before mdbx_env_open(). Once the database is
   * created, the page size cannot be changed. If you do not specify all or some
   * of the parameters, the corresponding default values will be used. For
   * instance, the default for database size is 10485760 bytes.
   *
   * If the mapsize is increased by another process, MDBX silently and
   * transparently adopt these changes at next transaction start. However,
   * \ref mdbx_txn_begin() will return \ref MDBX_UNABLE_EXTEND_MAPSIZE if new
   * mapping size could not be applied for current process (for instance if
   * address space is busy).  Therefore, in the case of
   * \ref MDBX_UNABLE_EXTEND_MAPSIZE error you need close and reopen the
   * environment to resolve error.
   *
   * \note Actual values may be different than your have specified because of
   * rounding to specified database page size, the system page size and/or the
   * size of the system virtual memory management unit. You can get actual values
   * by \ref mdbx_env_sync_ex() or see by using the tool `mdbx_chk` with the `-v`
   * option.
   *
   * Legacy \ref mdbx_env_set_mapsize() correspond to calling
   * \ref mdbx_env_set_geometry() with the arguments `size_lower`, `size_now`,
   * `size_upper` equal to the `size` and `-1` (i.e. default) for all other
   * parameters.
   *
   * \param [in] env         An environment handle returned
   *                         by \ref mdbx_env_create()
   *
   * \param [in] size_lower  The lower bound of database size in bytes.
   *                         Zero value means "minimal acceptable",
   *                         and negative means "keep current or use default".
   *
   * \param [in] size_now    The size in bytes to setup the database size for
   *                         now. Zero value means "minimal acceptable", and
   *                         negative means "keep current or use default". So,
   *                         it is recommended always pass -1 in this argument
   *                         except some special cases.
   *
   * \param [in] size_upper The upper bound of database size in bytes.
   *                        Zero value means "minimal acceptable",
   *                        and negative means "keep current or use default".
   *                        It is recommended to avoid change upper bound while
   *                        database is used by other processes or threaded
   *                        (i.e. just pass -1 in this argument except absolutely
   *                        necessary). Otherwise you must be ready for
   *                        \ref MDBX_UNABLE_EXTEND_MAPSIZE error(s), unexpected
   *                        pauses during remapping and/or system errors like
   *                        "address busy", and so on. In other words, there
   *                        is no way to handle a growth of the upper bound
   *                        robustly because there may be a lack of appropriate
   *                        system resources (which are extremely volatile in
   *                        a multi-process multi-threaded environment).
   *
   * \param [in] growth_step  The growth step in bytes, must be greater than
   *                          zero to allow the database to grow. Negative value
   *                          means "keep current or use default".
   *
   * \param [in] shrink_threshold  The shrink threshold in bytes, must be greater
   *                               than zero to allow the database to shrink and
   *                               greater than growth_step to avoid shrinking
   *                               right after grow.
   *                               Negative value means "keep current
   *                               or use default". Default is 2*growth_step.
   *
   * \param [in] pagesize          The database page size for new database
   *                               creation or -1 otherwise. Must be power of 2
   *                               in the range between \ref MDBX_MIN_PAGESIZE and
   *                               \ref MDBX_MAX_PAGESIZE. Zero value means
   *                               "minimal acceptable", and negative means
   *                               "keep current or use default".
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL    An invalid parameter was specified,
   *                        or the environment has an active write transaction.
   * \retval MDBX_EPERM     Specific for Windows: Shrinking was disabled before
   *                        and now it wanna be enabled, but there are reading
   *                        threads that don't use the additional `SRWL` (that
   *                        is required to avoid Windows issues).
   * \retval MDBX_EACCESS   The environment opened in read-only.
   * \retval MDBX_MAP_FULL  Specified size smaller than the space already
   *                        consumed by the environment.
   * \retval MDBX_TOO_LARGE Specified size is too large, i.e. too many pages for
   *                        given size, or a 32-bit process requests too much
   *                        bytes for the 32-bit address space. */
  public func setGeometry(_ geometry: MDBXGeometry) throws {
    let code = mdbx_env_set_geometry(self._env,
                                     geometry.sizeLower,
                                     geometry.sizeNow,
                                     geometry.sizeUpper,
                                     geometry.growthStep,
                                     geometry.shrinkThreshold,
                                     geometry.pageSize)
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Sets a Handle-Slow-Readers callback to resolve database full/overflow
   * issue due to a reader(s) which prevents the old data from being recycled.
   * \ingroup c_err
   *
   * The callback will only be triggered when the database is full due to a
   * reader(s) prevents the old data from being recycled.
   *
   * \see mdbx_env_get_hsr()
   * \see long-lived-read
   *
   * \param [in] env             An environment handle returned
   *                             by \ref mdbx_env_create().
   * \param [in] hsr_callback    A \ref MDBX_hsr_func function
   *                             or NULL to disable.
   *
   * \returns A non-zero error value on failure and 0 on success. */
  
  public func setHandleSlowReaders(_ handle: MDBXEnvironmentHandleSlowRead?) throws {
    let code: Int32
    if let handle = handle {
      
      code = mdbx_env_set_hsr(self._env, self.cSetHandleSlowReaders({ (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
        let environement = MDBXEnvironment()
        environement._env = env
        
        let transaction = MDBXTransaction(environement)
        transaction._txn = txn
        
        return handle(environement, transaction, pid, tid, laggard, gap, space, retry)
      }))
    } else {
      code = mdbx_env_set_hsr(self._env, nil)
    }
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Registers the current thread as a reader for the environment.
   * \ingroup c_extra
   *
   * To perform read operations without blocking, a reader slot must be assigned
   * for each thread. However, this assignment requires a short-term lock
   * acquisition which is performed automatically. This function allows you to
   * assign the reader slot in advance and thus avoid capturing the blocker when
   * the read transaction starts firstly from current thread.
   * \see mdbx_thread_unregister()
   *
   * \note Threads are registered automatically the first time a read transaction
   *       starts. Therefore, there is no need to use this function, except in
   *       special cases.
   *
   * \param [in] env   An environment handle returned by \ref mdbx_env_create().
   *
   * \returns A non-zero error value on failure and 0 on success,
   * or \ref MDBX_RESULT_TRUE if thread is already registered. */
  public func register() throws {
    guard self._state == .opened else { return }
    
    let code = mdbx_thread_register(self._env)
    
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /** \brief Unregisters the current thread as a reader for the environment.
   * \ingroup c_extra
   *
   * To perform read operations without blocking, a reader slot must be assigned
   * for each thread. However, the assigned reader slot will remain occupied until
   * the thread ends or the environment closes. This function allows you to
   * explicitly release the assigned reader slot.
   * \see mdbx_thread_register()
   *
   * \param [in] env   An environment handle returned by \ref mdbx_env_create().
   *
   * \returns A non-zero error value on failure and 0 on success, or
   * \ref MDBX_RESULT_TRUE if thread is not registered or already unregistered. */
  public func unregister() throws {
    guard self._state == .opened else { return }
    
    let code = mdbx_thread_unregister(self._env)
    
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  // MARK: - Private
  
  private func cSetHandleSlowReaders(_ block: (@escaping @convention(block) (OpaquePointer?, OpaquePointer?, pid_t, pthread_t?, UInt64, UInt32, Int, Int32) -> Int32)) -> (@convention(c) (OpaquePointer?, OpaquePointer?, pid_t, pthread_t?, UInt64, UInt32, Int, Int32) -> Int32) {
    return unsafeBitCast(imp_implementationWithBlock(block), to: (@convention(c) (OpaquePointer?, OpaquePointer?, pid_t, pthread_t?, UInt64, UInt32, Int, Int32) -> Int32).self)
  }
}
