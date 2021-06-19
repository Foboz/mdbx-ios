//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/22/21.
//

import Foundation
import libmdbx

public typealias MDBXEnvironmentReaderListHandler<T> = (_ context: T?, _ num: Int32, _ slot: Int32, _ processId: pid_t, _ threadId: pthread_t?, _ txnId: UInt64, _ lag: UInt64, _ bytesUsed: Int, _ bytesRetained: Int) -> Int32

public extension MDBXEnvironment {
  /** \brief Return the file descriptor for the given environment.
   * \ingroup c_statinfo
   *
   * \note All MDBX file descriptors have `FD_CLOEXEC` and
   *       couldn't be used after exec() and or `fork()`.
   *
   * \param [in] env   An environment handle returned by \ref mdbx_env_create().
   * \param [out] fd   Address of a int to contain the descriptor.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL  An invalid parameter was specified. */
  
  func getFileDescriptor() throws -> Int32 {
    var value: Int32 = 0
    try withUnsafeMutablePointer(to: &value) { pointer in
      let code = mdbx_env_get_fd(_env, pointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
    
    return value
  }
  
  /** \brief Get environment flags.
   * \ingroup c_statinfo
   * \see mdbx_env_set_flags()
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create().
   * \param [out] flags  The address of an integer to store the flags.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL An invalid parameter was specified. */
  
  func getFlags() throws -> MDBXEnvironmentFlags {
    var rawValue: UInt32 = 0
    try withUnsafeMutablePointer(to: &rawValue) { pointer in
      let code = mdbx_env_get_flags(_env, pointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
    
    return .init(rawValue: rawValue)
  }
  
  /** \brief Get the maximum number of named databases for the environment.
   * \ingroup c_statinfo
   * \see mdbx_env_set_maxdbs()
   *
   * \param [in] env   An environment handle returned by \ref mdbx_env_create().
   * \param [out] dbs  Address to store the maximum number of databases.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL   An invalid parameter was specified. */
  
  func getMaxNumberOfDatabases() throws -> Int {
    var dbi: MDBX_dbi = 0
    try withUnsafeMutablePointer(to: &dbi) { pointer in
      let code = mdbx_env_get_maxdbs(_env, pointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
    
    return Int(dbi)
  }
  
  /** \brief Get the maximum size of keys can write.
   * \ingroup c_statinfo
   *
   * \param [in] env    An environment handle returned by \ref mdbx_env_create().
   * \param [in] flags  Database options (\ref MDBX_DUPSORT, \ref MDBX_INTEGERKEY
   *                    and so on). \see db_flags
   *
   * \returns The maximum size of a key can write,
   *          or -1 if something is wrong. */
  
  func getMaxKeySizeEx(flags: MDBXDatabaseFlags) -> Int {
    return Int(mdbx_env_get_maxkeysize_ex(_env, flags.MDBX_db_flags_t))
  }
  
  /** \brief Get the maximum number of threads/reader slots for the environment.
   * \ingroup c_statinfo
   * \see mdbx_env_set_maxreaders()
   *
   * \param [in] env       An environment handle returned
   *                       by \ref mdbx_env_create().
   * \param [out] readers  Address of an integer to store the number of readers.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL   An invalid parameter was specified. */
  
  func getMaxNumberOfReaders() throws -> Int {
    var readers: UInt32 = 0
    try withUnsafeMutablePointer(to: &readers) { pointer in
      let code = mdbx_env_get_maxreaders(_env, pointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
    
    return Int(readers)
  }
  
  /** \brief Get the maximum size of data we can write.
   * \ingroup c_statinfo
   *
   * \param [in] env    An environment handle returned by \ref mdbx_env_create().
   * \param [in] flags  Database options (\ref MDBX_DUPSORT, \ref MDBX_INTEGERKEY
   *                    and so on). \see db_flags
   *
   * \returns The maximum size of a data can write,
   *          or -1 if something is wrong. */
  
  func getMaxValSizeEx(flags: MDBXDatabaseFlags) -> Int {
    return Int(mdbx_env_get_maxvalsize_ex(_env, flags.MDBX_db_flags_t))
  }
  
  /** \brief Return the path that was used in mdbx_env_open().
   * \ingroup c_statinfo
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create()
   * \param [out] dest   Address of a string pointer to contain the path.
   *                     This is the actual string in the environment, not a
   *                     copy. It should not be altered in any way.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EINVAL  An invalid parameter was specified. */
  
  // TODO: getPath with tests
  func getPath() throws -> String {
    var intPointer: UnsafePointer<Int8>?
    
    try withUnsafeMutablePointer(to: &intPointer, { pointer in
      let code = mdbx_env_get_path(_env, pointer)
      guard code != 0, let error = MDBXError(code: code) else { return }
      throw error
    })
    guard let pathPointer = intPointer,
          let path = String(cString: pathPointer, encoding: .utf8) else {
      throw MDBXError.EINVAL
    }
    return path
  }
  
  /** \brief Return information about the MDBX environment.
   * \ingroup c_statinfo
   *
   * At least one of env or txn argument must be non-null. If txn is passed
   * non-null then stat will be filled accordingly to the given transaction.
   * Otherwise, if txn is null, then stat will be populated by a snapshot from
   * the last committed write transaction, and at next time, other information
   * can be returned.
   *
   * Legacy \ref mdbx_env_info() correspond to calling \ref mdbx_env_info_ex()
   * with the null `txn` argument.
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create()
   * \param [in] txn     A transaction handle returned by \ref mdbx_txn_begin()
   * \param [out] info   The address of an \ref MDBX_envinfo structure
   *                     where the information will be copied
   * \param [in] bytes   The size of \ref MDBX_envinfo.
   *
   * \returns A non-zero error value on failure and 0 on success. */
  
  func getInfoEx(transaction: MDBXTransaction) throws -> MDBXEnvironmentInfo {
    var info = MDBX_envinfo()
    let size = MemoryLayout.size(ofValue: info)
    
    try withUnsafeMutablePointer(to: &info) { pointer in
      let code = mdbx_env_info_ex(_env, transaction._txn, pointer, size)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
    
    let geo = MDBXEnvironmentInfo.GeoMeta(
      lower: info.mi_geo.lower,
      upper: info.mi_geo.upper,
      current: info.mi_geo.current,
      shrink: info.mi_geo.shrink,
      grow: info.mi_geo.grow
    )
    let boot = MDBXEnvironmentInfo.BootMeta(
      current: .init(x: info.mi_bootid.current.x, y: info.mi_bootid.current.y),
      meta0: .init(x: info.mi_bootid.meta0.x, y: info.mi_bootid.meta0.y),
      meta1: .init(x: info.mi_bootid.meta1.x, y: info.mi_bootid.meta1.y),
      meta2: .init(x: info.mi_bootid.meta2.x, y: info.mi_bootid.meta2.y)
    )
    return .init(
      geo: geo,
      bootId: boot,
      mapSize: info.mi_mapsize,
      lastPageNumber: info.mi_last_pgno,
      recentTxnId: info.mi_recent_txnid,
      latterReaderTxnId: info.mi_latter_reader_txnid,
      selfLatterReaderTxnId: info.mi_self_latter_reader_txnid,
      meta0_txnId: info.mi_meta0_txnid,
      meta0_sign: info.mi_meta0_sign,
      meta1_txnId: info.mi_meta1_txnid,
      meta1_sign: info.mi_meta1_sign,
      meta2_txnId: info.mi_meta2_txnid,
      meta2_sign: info.mi_meta2_sign,
      maxReaders: info.mi_maxreaders,
      numReaders: info.mi_numreaders,
      databasePageSize: info.mi_dxb_pagesize,
      systemPageSize: info.mi_sys_pagesize,
      unsyncVolume: info.mi_unsync_volume,
      autosyncThreshold: info.mi_autosync_threshold,
      timeSinceLastSync: info.mi_since_sync_seconds16dot16,
      autoSyncPeriod: info.mi_autosync_period_seconds16dot16,
      timeSinceLastReadersCheck: info.mi_since_reader_check_seconds16dot16,
      mode: info.mi_mode
    )
  }
  
  /** \brief Return statistics about the MDBX environment.
   * \ingroup c_statinfo
   *
   * At least one of env or txn argument must be non-null. If txn is passed
   * non-null then stat will be filled accordingly to the given transaction.
   * Otherwise, if txn is null, then stat will be populated by a snapshot from
   * the last committed write transaction, and at next time, other information
   * can be returned.
   *
   * Legacy mdbx_env_stat() correspond to calling \ref mdbx_env_stat_ex() with the
   * null `txn` argument.
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create()
   * \param [in] txn     A transaction handle returned by \ref mdbx_txn_begin()
   * \param [out] stat   The address of an \ref MDBX_stat structure where
   *                     the statistics will be copied
   * \param [in] bytes   The size of \ref MDBX_stat.
   *
   * \returns A non-zero error value on failure and 0 on success. */
  
  func getStatEx(transaction: MDBXTransaction) throws -> MDBXStat {
    var stat = MDBX_stat()
    let size = MemoryLayout.size(ofValue: stat)
    
    try withUnsafeMutablePointer(to: &stat) { pointer in
      let code = mdbx_env_stat_ex(_env, transaction._txn, pointer, size)
      
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
  
  /** \brief Enumerate the entries in the reader lock table.
   *
   * \ingroup c_statinfo
   *
   * \param [in] env     An environment handle returned by \ref mdbx_env_create().
   * \param [in] func    A \ref MDBX_reader_list_func function.
   * \param [in] ctx     An arbitrary context pointer for the enumeration
   *                     function.
   *
   * \returns A non-zero error value on failure and 0 on success,
   * or \ref MDBX_RESULT_TRUE if the reader lock table is empty. */
  
  func readerList<T>(handler: @escaping MDBXEnvironmentReaderListHandler<T>, context: inout T) throws {
    try withUnsafeMutableBytes(of: &context) { pointer in
      let code = mdbx_reader_list(_env, self.cSetHandleReaderList({ (ctx, num, slot, processId, threadId, txnId, lag, bytesUsed, bytesRetained) -> Int32 in
        let context = ctx?.load(as: T.self)
        return handler(context, num, slot, processId, threadId, txnId, lag, bytesUsed, bytesRetained)
      }), pointer.baseAddress)
      
      guard code > 0, let error = MDBXError(code: code) else {
        return
      }
      throw error
    }
  }
  
  private func cSetHandleReaderList(_ block: (@escaping @convention(block) (UnsafeMutableRawPointer?, Int32, Int32, pid_t, pthread_t?, UInt64, UInt64, Int, Int) -> Int32)) -> (@convention(c) (UnsafeMutableRawPointer?, Int32, Int32, pid_t, pthread_t?, UInt64, UInt64, Int, Int) -> Int32) {
    return unsafeBitCast(imp_implementationWithBlock(block), to: (@convention(c) (UnsafeMutableRawPointer?, Int32, Int32, pid_t, pthread_t?, UInt64, UInt64, Int, Int) -> Int32).self)
  }
}
