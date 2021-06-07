//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/19/21.
//

import Foundation
import libmdbx_ios

public extension MDBXCursor {
  /** \brief Return count of duplicates for current key.
   * \ingroup c_cursors c_crud
   *
   * This call is valid for all databases, but reasonable only for that support
   * sorted duplicate data items \ref MDBX_DUPSORT.
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   * \param [out] pcount   Address where the count will be stored.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_EINVAL   Cursor is not initialized, or an invalid parameter
   *                       was specified. */

  func count() throws -> Int {
    var pCount = 0
    try withUnsafeMutablePointer(to: &pCount) { pointer in
      let code = mdbx_cursor_count(_cursor, pointer)
      
      
      guard code != 0, let error = MDBXError(code: code) else {
        return
      }

      throw error
    }
    return pCount
  }
  
  /** \brief Delete current key/data pair.
   * \ingroup c_cursors c_crud
   *
   * This function deletes the key/data pair to which the cursor refers. This
   * does not invalidate the cursor, so operations such as \ref MDBX_NEXT can
   * still be used on it. Both \ref MDBX_NEXT and \ref MDBX_GET_CURRENT will
   * return the same record after this operation.
   *
   * \param [in] cursor  A cursor handle returned by mdbx_cursor_open().
   * \param [in] flags   Options for this operation. This parameter must be set
   * to one of the values described here.
   *
   *  - \ref MDBX_CURRENT Delete only single entry at current cursor position.
   *  - \ref MDBX_ALLDUPS
   *    or \ref MDBX_NODUPDATA (supported for compatibility)
   *      Delete all of the data items for the current key. This flag has effect
   *      only for database(s) was created with \ref MDBX_DUPSORT.
   *
   * \see \ref c_crud_hints "Quick reference for Insert/Update/Delete operations"
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_MAP_FULL      The database is full,
   *                            see \ref mdbx_env_set_mapsize().
   * \retval MDBX_TXN_FULL      The transaction has too many dirty pages.
   * \retval MDBX_EACCES        An attempt was made to write in a read-only
   *                            transaction.
   * \retval MDBX_EINVAL        An invalid parameter was specified. */

  func delete(flags: MDBXPutFlags) throws {
    let code = mdbx_cursor_del(_cursor, flags.MDBX_put_flags_t)
    
    guard code != 0, let error = MDBXError(code: code) else {
      return
    }

    throw error
  }
  
  /** \brief Retrieve by cursor.
   * \ingroup c_cursors c_crud
   *
   * This function retrieves key/data pairs from the database. The address and
   * length of the key are returned in the object to which key refers (except
   * for the case of the \ref MDBX_SET option, in which the key object is
   * unchanged), and the address and length of the data are returned in the object
   * to which data refers.
   * \see mdbx_get()
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   * \param [in,out] key   The key for a retrieved item.
   * \param [in,out] data  The data of a retrieved item.
   * \param [in] op        A cursor operation \ref MDBX_cursor_op.
   *
   * \returns A non-zero error value on failure and 0 on success,
   *          some possible errors are:
   * \retval MDBX_THREAD_MISMATCH  Given transaction is not owned
   *                               by current thread.
   * \retval MDBX_NOTFOUND  No matching key found.
   * \retval MDBX_EINVAL    An invalid parameter was specified. */

  func getValue(key: inout Data, operation: MDBXCursorOperations) throws -> Data {
    let keyCount = key.count
    var localKey = key
    return try localKey.withUnsafeMutableBytes { keyPointer in
      var mdbxKey = MDBX_val()
      mdbxKey.iov_base = keyPointer.baseAddress
      mdbxKey.iov_len = keyCount
      var mdbxData = MDBX_val()
      
      let code = mdbx_cursor_get(_cursor, &mdbxKey, &mdbxData, operation.MDBX_cursor_op)
      let txn = mdbx_cursor_txn(_cursor)
      
      if mdbx_is_dirty(txn, mdbxKey.iov_base) == MDBX_RESULT_FALSE.rawValue {
        key = mdbxKey.dataNoCopy
      } else {
        key = mdbxKey.data
      }
      
      guard code != 0, let error = MDBXError(code: code) else {
        guard mdbx_is_dirty(txn, mdbxData.iov_base) == MDBX_RESULT_FALSE.rawValue else {
          return mdbxData.data
        }
        return mdbxData.dataNoCopy
      }
      
      throw error
    }
  }
  
  /** \brief Store by cursor.
   * \ingroup c_cursors c_crud
   *
   * This function stores key/data pairs into the database. The cursor is
   * positioned at the new item, or on failure usually near it.
   *
   * \param [in] cursor    A cursor handle returned by \ref mdbx_cursor_open().
   * \param [in] key       The key operated on.
   * \param [in,out] data  The data operated on.
   * \param [in] flags     Options for this operation. This parameter
   *                       must be set to 0 or by bitwise OR'ing together
   *                       one or more of the values described here:
   *  - \ref MDBX_CURRENT
   *      Replace the item at the current cursor position. The key parameter
   *      must still be provided, and must match it, otherwise the function
   *      return \ref MDBX_EKEYMISMATCH. With combination the
   *      \ref MDBX_ALLDUPS will replace all multi-values.
   *
   *      \note MDBX allows (unlike LMDB) you to change the size of the data and
   *      automatically handles reordering for sorted duplicates
   *      (see \ref MDBX_DUPSORT).
   *
   *  - \ref MDBX_NODUPDATA
   *      Enter the new key-value pair only if it does not already appear in the
   *      database. This flag may only be specified if the database was opened
   *      with \ref MDBX_DUPSORT. The function will return \ref MDBX_KEYEXIST
   *      if the key/data pair already appears in the database.
   *
   *  - \ref MDBX_NOOVERWRITE
   *      Enter the new key/data pair only if the key does not already appear
   *      in the database. The function will return \ref MDBX_KEYEXIST if the key
   *      already appears in the database, even if the database supports
   *      duplicates (\ref MDBX_DUPSORT).
   *
   *  - \ref MDBX_RESERVE
   *      Reserve space for data of the given size, but don't copy the given
   *      data. Instead, return a pointer to the reserved space, which the
   *      caller can fill in later - before the next update operation or the
   *      transaction ends. This saves an extra memcpy if the data is being
   *      generated later. This flag must not be specified if the database
   *      was opened with \ref MDBX_DUPSORT.
   *
   *  - \ref MDBX_APPEND
   *      Append the given key/data pair to the end of the database. No key
   *      comparisons are performed. This option allows fast bulk loading when
   *      keys are already known to be in the correct order. Loading unsorted
   *      keys with this flag will cause a \ref MDBX_KEYEXIST error.
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
   * \retval MDBX_EKEYMISMATCH  The given key value is mismatched to the current
   *                            cursor position
   * \retval MDBX_MAP_FULL      The database is full,
   *                             see \ref mdbx_env_set_mapsize().
   * \retval MDBX_TXN_FULL      The transaction has too many dirty pages.
   * \retval MDBX_EACCES        An attempt was made to write in a read-only
   *                            transaction.
   * \retval MDBX_EINVAL        An invalid parameter was specified. */

  func put(value: inout Data, key: inout Data, flags: MDBXPutFlags) throws {
    let keyCount = key.count
    let valueCount = value.count
    
    try key.withUnsafeMutableBytes { keyPointer in
        var mdbxKey = MDBX_val()
        mdbxKey.iov_base = keyPointer.baseAddress
        mdbxKey.iov_len = keyCount
        
        try value.withUnsafeMutableBytes { valuePointer in
            var mdbxData = MDBX_val()
            mdbxData.iov_base = valuePointer.baseAddress
            mdbxData.iov_len = valueCount
            
            let code = mdbx_cursor_put(_cursor, &mdbxKey, &mdbxData, flags.MDBX_put_flags_t)
            
            guard code != 0, let error = MDBXError(code: code) else {
              return
            }

            throw error
        }
    }
  }
}
