//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/15/21.
//

import Foundation
import libmdbx_ios

extension MDBXTransaction {
  /** \brief Get items from a database.
   * \ingroup c_crud
   *
   * This function retrieves key/data pairs from the database. The address
   * and length of the data associated with the specified key are returned
   * in the structure to which data refers.
   * If the database supports duplicate keys (\ref MDBX_DUPSORT) then the
   * first data item for the key will be returned. Retrieval of other
   * items requires the use of \ref mdbx_cursor_get().
   *
   * \note The memory pointed to by the returned values is owned by the
   * database. The caller need not dispose of the memory, and may not
   * modify it in any way. For values returned in a read-only transaction
   * any modification attempts will cause a `SIGSEGV`.
   *
   * \note Values returned from the database are valid only until a
   * subsequent update operation, or the end of the transaction.
   *
   * \param [in] txn       A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi       A database handle returned by \ref mdbx_dbi_open().
   * \param [in] key       The key to search for in the database.
   * \param [in,out] data  The data corresponding to the key.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_NOTFOUND  The key was not in the database.
   * \retval MDBX_EINVAL    An invalid parameter was specified.*/

  func getValue(for key: Data, database: MDBXDatabase) throws -> Data {
    var mdbxKey = key.mdbxVal

    let mdbxVal = try withUnsafePointer(to: &mdbxKey) { keyPointer -> MDBX_val in
      var data: MDBX_val = .init()
      try withUnsafeMutablePointer(to: &data) { pointer in
        let code = mdbx_get(_txn, database._dbi, keyPointer, pointer)
        guard code != 0, let error = MDBXError(code: code) else {
          return
        }

        throw error
      }
      
      return data
    }
        
    return mdbxVal.data
  }
  
  /** \brief Get equal or great item from a database.
   * \ingroup c_crud
   *
   * Briefly this function does the same as \ref mdbx_get() with a few
   * differences:
   * 1. Return equal or great (due comparison function) key-value
   *    pair, but not only exactly matching with the key.
   * 2. On success return \ref MDBX_SUCCESS if key found exactly,
   *    and \ref MDBX_RESULT_TRUE otherwise. Moreover, for databases with
   *    \ref MDBX_DUPSORT flag the data argument also will be used to match over
   *    multi-value/duplicates, and \ref MDBX_SUCCESS will be returned only when
   *    BOTH the key and the data match exactly.
   * 3. Updates BOTH the key and the data for pointing to the actual key-value
   *    pair inside the database.
   *
   * \param [in] txn           A transaction handle returned
   *                           by \ref mdbx_txn_begin().
   * \param [in] dbi           A database handle returned by \ref mdbx_dbi_open().
   * \param [in,out] key       The key to search for in the database.
   * \param [in,out] data      The data corresponding to the key.
   *
   * \returns A non-zero error value on failure and \ref MDBX_RESULT_FALSE
   *          or \ref MDBX_RESULT_TRUE on success (as described above).
   *          Some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_NOTFOUND      The key was not in the database.
   * \retval MDBX_EINVAL        An invalid parameter was specified. */

  func getValueEqualOrGreater(for key: inout Data, database: MDBXDatabase) throws -> Data {
    var mdbxKey = key.mdbxVal

    let mdbxVal = try withUnsafeMutablePointer(to: &mdbxKey) { keyPointer -> MDBX_val in
      var data: MDBX_val = .init()
      try withUnsafeMutablePointer(to: &data) { pointer in
        let code = mdbx_get_equal_or_great(_txn, database._dbi, keyPointer, pointer)
        guard code != 0, let error = MDBXError(code: code) else {
          return
        }

        throw error
      }
      
      return data
    }
    
    key = mdbxKey.data
    return mdbxVal.data
  }
  
  /** \brief Get items from a database
   * and optionally number of data items for a given key.
   *
   * \ingroup c_crud
   *
   * Briefly this function does the same as \ref mdbx_get() with a few
   * differences:
   *  1. If values_count is NOT NULL, then returns the count
   *     of multi-values/duplicates for a given key.
   *  2. Updates BOTH the key and the data for pointing to the actual key-value
   *     pair inside the database.
   *
   * \param [in] txn           A transaction handle returned
   *                           by \ref mdbx_txn_begin().
   * \param [in] dbi           A database handle returned by \ref mdbx_dbi_open().
   * \param [in,out] key       The key to search for in the database.
   * \param [in,out] data      The data corresponding to the key.
   * \param [out] values_count The optional address to return number of values
   *                           associated with given key:
   *                            = 0 - in case \ref MDBX_NOTFOUND error;
   *                            = 1 - exactly for databases
   *                                  WITHOUT \ref MDBX_DUPSORT;
   *                            >= 1 for databases WITH \ref MDBX_DUPSORT.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_NOTFOUND  The key was not in the database.
   * \retval MDBX_EINVAL    An invalid parameter was specified. */
  func getValueEx(for key: inout Data, database: MDBXDatabase, valuesCount: inout Int) throws -> Data {
    var mdbxKey = key.mdbxVal

    let mdbxVal = try withUnsafeMutablePointer(to: &mdbxKey) { keyPointer -> MDBX_val in
      var data: MDBX_val = .init()
      try withUnsafeMutablePointer(to: &data) { pointer in
        try withUnsafeMutablePointer(to: &valuesCount) { countPointer in
          let code = mdbx_get_ex(_txn, database._dbi, keyPointer, pointer, countPointer)
          guard code != 0, let error = MDBXError(code: code) else {
            return
          }

          throw error
        }
      }
      
      return data
    }
    
    key = mdbxKey.data
    return mdbxVal.data
  }
  
  /** \brief Store items into a database.
   * \ingroup c_crud
   *
   * This function stores key/data pairs in the database. The default behavior
   * is to enter the new key/data pair, replacing any previously existing key
   * if duplicates are disallowed, or adding a duplicate data item if
   * duplicates are allowed (see \ref MDBX_DUPSORT).
   *
   * \param [in] txn        A transaction handle returned
   *                        by \ref mdbx_txn_begin().
   * \param [in] dbi        A database handle returned by \ref mdbx_dbi_open().
   * \param [in] key        The key to store in the database.
   * \param [in,out] data   The data to store.
   * \param [in] flags      Special options for this operation.
   *                        This parameter must be set to 0 or by bitwise OR'ing
   *                        together one or more of the values described here:
   *   - \ref MDBX_NODUPDATA
   *      Enter the new key-value pair only if it does not already appear
   *      in the database. This flag may only be specified if the database
   *      was opened with \ref MDBX_DUPSORT. The function will return
   *      \ref MDBX_KEYEXIST if the key/data pair already appears in the database.
   *
   *  - \ref MDBX_NOOVERWRITE
   *      Enter the new key/data pair only if the key does not already appear
   *      in the database. The function will return \ref MDBX_KEYEXIST if the key
   *      already appears in the database, even if the database supports
   *      duplicates (see \ref  MDBX_DUPSORT). The data parameter will be set
   *      to point to the existing item.
   *
   *  - \ref MDBX_CURRENT
   *      Update an single existing entry, but not add new ones. The function will
   *      return \ref MDBX_NOTFOUND if the given key not exist in the database.
   *      In case multi-values for the given key, with combination of
   *      the \ref MDBX_ALLDUPS will replace all multi-values,
   *      otherwise return the \ref MDBX_EMULTIVAL.
   *
   *  - \ref MDBX_RESERVE
   *      Reserve space for data of the given size, but don't copy the given
   *      data. Instead, return a pointer to the reserved space, which the
   *      caller can fill in later - before the next update operation or the
   *      transaction ends. This saves an extra memcpy if the data is being
   *      generated later. MDBX does nothing else with this memory, the caller
   *      is expected to modify all of the space requested. This flag must not
   *      be specified if the database was opened with \ref MDBX_DUPSORT.
   *
   *  - \ref MDBX_APPEND
   *      Append the given key/data pair to the end of the database. This option
   *      allows fast bulk loading when keys are already known to be in the
   *      correct order. Loading unsorted keys with this flag will cause
   *      a \ref MDBX_EKEYMISMATCH error.
   *
   *  - \ref MDBX_APPENDDUP
   *      As above, but for sorted dup data.
   *
   *  - \ref MDBX_MULTIPLE
   *      Store multiple contiguous data elements in a single request. This flag
   *      may only be specified if the database was opened with
   *      \ref MDBX_DUPFIXED. With combination the \ref MDBX_ALLDUPS
   *      will replace all multi-values.
   *      The data argument must be an array of two \ref MDBX_val. The `iov_len`
   *      of the first \ref MDBX_val must be the size of a single data element.
   *      The `iov_base` of the first \ref MDBX_val must point to the beginning
   *      of the array of contiguous data elements which must be properly aligned
   *      in case of database with \ref MDBX_INTEGERDUP flag.
   *      The `iov_len` of the second \ref MDBX_val must be the count of the
   *      number of data elements to store. On return this field will be set to
   *      the count of the number of elements actually written. The `iov_base` of
   *      the second \ref MDBX_val is unused.
   *
   * \see \ref c_crud_hints "Quick reference for Insert/Update/Delete operations"
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_KEYEXIST  The key/value pair already exists in the database.
   * \retval MDBX_MAP_FULL  The database is full, see \ref mdbx_env_set_mapsize().
   * \retval MDBX_TXN_FULL  The transaction has too many dirty pages.
   * \retval MDBX_EACCES    An attempt was made to write
   *                        in a read-only transaction.
   * \retval MDBX_EINVAL    An invalid parameter was specified. */

  func put(
    value: Data,
    forKey key: Data,
    database: MDBXDatabase,
    flags: MDBXPutFlags
  ) throws {
    var mdbxKey = key.mdbxVal
    try withUnsafePointer(to: &mdbxKey) {  keyPointer in
      var mdbxValue = value.mdbxVal
      try withUnsafeMutablePointer(to: &mdbxValue) { valuePointer in
        let code = mdbx_put(_txn, database._dbi, keyPointer, valuePointer, flags.MDBX_put_flags_t)
        
        guard code != 0, let error = MDBXError(code: code) else {
          return
        }

        throw error
      }
    }
  }
  
  /** \brief Delete items from a database.
   * \ingroup c_crud
   *
   * This function removes key/data pairs from the database.
   *
   * \note The data parameter is NOT ignored regardless the database does
   * support sorted duplicate data items or not. If the data parameter
   * is non-NULL only the matching data item will be deleted. Otherwise, if data
   * parameter is NULL, any/all value(s) for specified key will be deleted.
   *
   * This function will return \ref MDBX_NOTFOUND if the specified key/data
   * pair is not in the database.
   *
   * \see \ref c_crud_hints "Quick reference for Insert/Update/Delete operations"
   *
   * \param [in] txn   A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi   A database handle returned by \ref mdbx_dbi_open().
   * \param [in] key   The key to delete from the database.
   * \param [in] data  The data to delete.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_EACCES   An attempt was made to write
   *                       in a read-only transaction.
   * \retval MDBX_EINVAL   An invalid parameter was specified. */

  func delete(value: Data? = nil, key: Data, database: MDBXDatabase) throws {
    var mdbxKey = key.mdbxVal
    let code = withUnsafePointer(to: &mdbxKey) { keyPointer -> Int32 in
      var mdbxValue = value?.mdbxVal
      if mdbxValue != nil {
        return withUnsafeMutablePointer(to: &mdbxValue!) { valuePointer -> Int32 in
          return mdbx_del(_txn, database._dbi, keyPointer, valuePointer)
        }
      } else {
        return mdbx_del(_txn, database._dbi, keyPointer, nil)
      }
    }
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }

    throw error
  }
  
  /** \brief Empty or delete and close a database.
   * \ingroup c_crud
   *
   * \see mdbx_dbi_close() \see mdbx_dbi_open()
   *
   * \param [in] txn  A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi  A database handle returned by \ref mdbx_dbi_open().
   * \param [in] del  `false` to empty the DB, `true` to delete it
   *                  from the environment and close the DB handle.
   *
   * \returns A non-zero error value on failure and 0 on success. */

  func drop(database: MDBXDatabase, delete: Bool) throws {
    let code = mdbx_drop(_txn, database._dbi, delete)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }

    throw error
  }
  
  /** \brief Replace items in a database.
   * \ingroup c_crud
   *
   * This function allows to update or delete an existing value at the same time
   * as the previous value is retrieved. If the argument new_data equal is NULL
   * zero, the removal is performed, otherwise the update/insert.
   *
   * The current value may be in an already changed (aka dirty) page. In this
   * case, the page will be overwritten during the update, and the old value will
   * be lost. Therefore, an additional buffer must be passed via old_data
   * argument initially to copy the old value. If the buffer passed in is too
   * small, the function will return \ref MDBX_RESULT_TRUE by setting iov_len
   * field pointed by old_data argument to the appropriate value, without
   * performing any changes.
   *
   * For databases with non-unique keys (i.e. with \ref MDBX_DUPSORT flag),
   * another use case is also possible, when by old_data argument selects a
   * specific item from multi-value/duplicates with the same key for deletion or
   * update. To select this scenario in flags should simultaneously specify
   * \ref MDBX_CURRENT and \ref MDBX_NOOVERWRITE. This combination is chosen
   * because it makes no sense, and thus allows you to identify the request of
   * such a scenario.
   *
   * \param [in] txn           A transaction handle returned
   *                           by \ref mdbx_txn_begin().
   * \param [in] dbi           A database handle returned by \ref mdbx_dbi_open().
   * \param [in] key           The key to store in the database.
   * \param [in] new_data      The data to store, if NULL then deletion will
   *                           be performed.
   * \param [in,out] old_data  The buffer for retrieve previous value as describe
   *                           above.
   * \param [in] flags         Special options for this operation.
   *                           This parameter must be set to 0 or by bitwise
   *                           OR'ing together one or more of the values
   *                           described in \ref mdbx_put() description above,
   *                           and additionally
   *                           (\ref MDBX_CURRENT | \ref MDBX_NOOVERWRITE)
   *                           combination for selection particular item from
   *                           multi-value/duplicates.
   *
   * \see \ref c_crud_hints "Quick reference for Insert/Update/Delete operations"
   *
   * \returns A non-zero error value on failure and 0 on success. */

  func replace(
    new: Data,
    forKey key: Data,
    database: MDBXDatabase,
    flags: MDBXPutFlags
  ) throws -> Data {
    var mdbxKey = key.mdbxVal
    var oldMdbxValue = MDBX_val()
    try withUnsafePointer(to: &mdbxKey) {  keyPointer in
      var newMdbxValue = new.mdbxVal
      try withUnsafeMutablePointer(to: &oldMdbxValue) { oldValuePointer in
        try withUnsafeMutablePointer(to: &newMdbxValue) { newValuePointer in
          let code = mdbx_replace(_txn, database._dbi, keyPointer, newValuePointer, oldValuePointer, flags.MDBX_put_flags_t)
          
          guard code != 0, let error = MDBXError(code: code) else {
            return
          }

          throw error
        }
      }
    }
    
    return oldMdbxValue.data
  }
  
  /** \brief Compare two keys according to a particular database.
   * \ingroup c_crud
   *
   * This returns a comparison as if the two data items were keys in the
   * specified database.
   *
   * \warning There ss a Undefined behavior if one of arguments is invalid.
   *
   * \param [in] txn   A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi   A database handle returned by \ref mdbx_dbi_open().
   * \param [in] a     The first item to compare.
   * \param [in] b     The second item to compare.
   *
   * \returns < 0 if a < b, 0 if a == b, > 0 if a > b */

  func compare(a: Data, b: Data, database: MDBXDatabase) -> Int32 {
    var mdbxA = a.mdbxVal
    var mdbxB = b.mdbxVal
    
    return withUnsafeMutablePointer(to: &mdbxA) { aPointer in
      withUnsafeMutablePointer(to: &mdbxB) { bPointer in
        return mdbx_cmp(_txn, database._dbi, aPointer, bPointer)
      }
    }
  }
  
  /** \brief Sequence generation for a database.
   * \ingroup c_crud
   *
   * The function allows to create a linear sequence of unique positive integers
   * for each database. The function can be called for a read transaction to
   * retrieve the current sequence value, and the increment must be zero.
   * Sequence changes become visible outside the current write transaction after
   * it is committed, and discarded on abort.
   *
   * \param [in] txn        A transaction handle returned
   *                        by \ref mdbx_txn_begin().
   * \param [in] dbi        A database handle returned by \ref mdbx_dbi_open().
   * \param [out] result    The optional address where the value of sequence
   *                        before the change will be stored.
   * \param [in] increment  Value to increase the sequence,
   *                        must be 0 for read-only transactions.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_RESULT_TRUE   Increasing the sequence has resulted in an
   *                            overflow and therefore cannot be executed. */

  func dbiSequence(database: MDBXDatabase, increment: UInt64) throws -> UInt64 {
    var result: UInt64 = 0
    try withUnsafeMutablePointer(to: &result) { pointer in
      let code = mdbx_dbi_sequence(_txn, database._dbi, pointer, increment)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }

      throw error
    }
    
    return result
  }
  
  /** \brief Compare two data items according to a particular database.
   * \ingroup c_crud
   *
   * This returns a comparison as if the two items were data items of the
   * specified database.
   *
   * \warning There ss a Undefined behavior if one of arguments is invalid.
   *
   * \param [in] txn   A transaction handle returned by \ref mdbx_txn_begin().
   * \param [in] dbi   A database handle returned by \ref mdbx_dbi_open().
   * \param [in] a     The first item to compare.
   * \param [in] b     The second item to compare.
   *
   * \returns < 0 if a < b, 0 if a == b, > 0 if a > b */

  func databaseCompare(a: Data, b: Data, database: MDBXDatabase) -> Int32 {
    var mdbxA = a.mdbxVal
    var mdbxB = b.mdbxVal
    
    return withUnsafeMutablePointer(to: &mdbxA) { aPointer in
      withUnsafeMutablePointer(to: &mdbxB) { bPointer in
        return mdbx_dcmp(_txn, database._dbi, aPointer, bPointer)
      }
    }
  }
  
  /** \brief Commit all the operations of a transaction into the database and
   * collect latency information.
   * \see mdbx_txn_commit()
   * \ingroup c_statinfo
   * \warning This function may be changed in future releases. */

  func commitEx() throws -> MDBXCommitLatency {
    var latency = MDBX_commit_latency()
    try withUnsafeMutablePointer(to: &latency) { pointer in
     let code = mdbx_txn_commit_ex(_txn, pointer)
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }

      throw error
    }
    
    return .init(
      preparation: latency.preparation,
      gc: latency.gc,
      audit: latency.audit,
      write: latency.write,
      sync: latency.sync,
      ending: latency.ending,
      whole: latency.whole
    )
  }
}
