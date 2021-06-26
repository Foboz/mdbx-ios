//
//  MDBXError.swift
//  mdbx-ios
//
//  Created by Mikhail Nikanorov on 4/7/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

public enum MDBXError: LocalizedError {
  init?(code: Int32) {
    switch code {
    case libmdbx.MDBX_KEYEXIST.rawValue:                  self = .keyExist
    case libmdbx.MDBX_FIRST_LMDB_ERRCODE.rawValue:        self = .firstLMDBErrorCode
    case libmdbx.MDBX_NOTFOUND.rawValue:                  self = .notFound
    case libmdbx.MDBX_PAGE_NOTFOUND.rawValue:             self = .pageNotFound
    case libmdbx.MDBX_CORRUPTED.rawValue:                 self = .corrupted
    case libmdbx.MDBX_PANIC.rawValue:                     self = .panic
    case libmdbx.MDBX_VERSION_MISMATCH.rawValue:          self = .versionMismatch
    case libmdbx.MDBX_INVALID.rawValue:                   self = .invalid
    case libmdbx.MDBX_MAP_FULL.rawValue:                  self = .mapFull
    case libmdbx.MDBX_DBS_FULL.rawValue:                  self = .dbsFull
    case libmdbx.MDBX_READERS_FULL.rawValue:              self = .readersFull
    case libmdbx.MDBX_TXN_FULL.rawValue:                  self = .txnFull
    case libmdbx.MDBX_CURSOR_FULL.rawValue:               self = .cursorFull
    case libmdbx.MDBX_PAGE_FULL.rawValue:                 self = .pageFull
    case libmdbx.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue:     self = .unableExtendMapsize
    case libmdbx.MDBX_INCOMPATIBLE.rawValue:              self = .incompatible
    case libmdbx.MDBX_BAD_RSLOT.rawValue:                 self = .badReadSlot
    case libmdbx.MDBX_BAD_TXN.rawValue:                   self = .badTransaction
    case libmdbx.MDBX_BAD_VALSIZE.rawValue:               self = .badValSize
    case libmdbx.MDBX_BAD_DBI.rawValue:                   self = .badDatabase
    case libmdbx.MDBX_PROBLEM.rawValue:                   self = .problem
    case libmdbx.MDBX_LAST_LMDB_ERRCODE.rawValue:         self = .lastLMDBErrorCode
    case libmdbx.MDBX_BUSY.rawValue:                      self = .busy
    case libmdbx.MDBX_FIRST_ADDED_ERRCODE.rawValue:       self = .firstAddedErrorCode
    case libmdbx.MDBX_EMULTIVAL.rawValue:                 self = .multipleValues
    case libmdbx.MDBX_EBADSIGN.rawValue:                  self = .badSignature
    case libmdbx.MDBX_WANNA_RECOVERY.rawValue:            self = .wannaRecovery
    case libmdbx.MDBX_EKEYMISMATCH.rawValue:              self = .keyMismatch
    case libmdbx.MDBX_TOO_LARGE.rawValue:                 self = .tooLarge
    case libmdbx.MDBX_THREAD_MISMATCH.rawValue:           self = .threadMismatch
    case libmdbx.MDBX_TXN_OVERLAPPING.rawValue:           self = .transactionsOverlapping
    case libmdbx.MDBX_LAST_ADDED_ERRCODE.rawValue:        self = .lastAddedErrorCode
    case libmdbx.MDBX_ENODATA.rawValue:                   self = .ENODATA
    case libmdbx.MDBX_EINVAL.rawValue:                    self = .EINVAL
    case libmdbx.MDBX_EACCESS.rawValue:                   self = .EACCESS
    case libmdbx.MDBX_ENOMEM.rawValue:                    self = .ENOMEM
    case libmdbx.MDBX_EROFS.rawValue:                     self = .EROFS
    case libmdbx.MDBX_ENOSYS.rawValue:                    self = .ENOSYS
    case libmdbx.MDBX_EIO.rawValue:                       self = .EIO
    case libmdbx.MDBX_EPERM.rawValue:                     self = .EPERM
    case libmdbx.MDBX_EINTR.rawValue:                     self = .EINTR
    case libmdbx.MDBX_ENOFILE.rawValue:                   self = .ENOFILE
    case libmdbx.MDBX_EREMOTE.rawValue:                   self = .EREMOTE
    default: return nil
    }
  }
  
  /**
   * key/data pair already exists
   *
   * - Tag: MDBXError.keyExist
   */
  case keyExist
  /**
   *  The first LMDB-compatible defined error code
   *
   * - Tag: MDBXError.firstLMDBErrorCode
   */
  case firstLMDBErrorCode
  /**
   * key/data pair not found (EOF)
   *
   * - Tag: MDBXError.notFound
   */
  case notFound
  /**
   * Requested page not found - this usually indicates corruption
   *
   * - Tag: MDBXError.pageNotFound
   */
  case pageNotFound
  /**
   * Database is corrupted (page was wrong type and so on)
   *
   * - Tag: MDBXError.corrupted
   */
  case corrupted
  /**
   * Environment had fatal error, i.e. update of meta page failed and so on.
   *
   * - Tag: MDBXError.panic
   */
  case panic
  /**
   * DB file version mismatch with libmdbx
   *
   * - Tag: MDBXError.versionMismatch
   */
  case versionMismatch
  /**
   * File is not a valid MDBX file
   *
   * - Tag: MDBXError.invalid
   */
  case invalid
  /**
   * Environment mapsize reached
   *
   * - Tag: MDBXError.mapFull
   */
  case mapFull
  /**
   * Environment maxdbs reached
   *
   * - Tag: MDBXError.dbsFull
   */
  case dbsFull
  /**
   * Environment maxreaders reached
   *
   * - Tag: MDBXError.readersFull
   */
  case readersFull
  /**
   * Transaction has too many dirty pages, i.e transaction too big
   *
   * - Tag: MDBXError.txnFull
   */
  case txnFull
  /**
   * Cursor stack too deep - this usually indicates corruption, i.e branch-pages loop
   *
   * - Tag: MDBXError.cursorFull
   */
  case cursorFull
  /**
   * Page has not enough space - internal error
   *
   * - Tag: MDBXError.pageFull
   */
  case pageFull
  /**
   * Database engine was unable to extend mapping, e.g. since address space is unavailable or busy. This can mean:
   *
   * - Database size extended by other process beyond to environment mapsize and engine was unable to extend mapping while starting read transaction. Environment should be reopened to continue.
   * - Engine was unable to extend mapping during write transaction or explicit call of mdbx_env_set_geometry().
   *
   * - Tag: MDBXError.unableExtendMapsize
   */
  case unableExtendMapsize
  /**
   * Environment or database is not compatible with the requested operation or the specified flags. This can mean:
   *
   * - The operation expects an MDBX_DUPSORT / MDBX_DUPFIXED database.
   * - Opening a named DB when the unnamed DB has MDBX_DUPSORT / MDBX_INTEGERKEY.
   * - Accessing a data record as a database, or vice versa.
   * - The database was dropped and recreated with different flags.
   *
   * - Tag: MDBXError.incompatible
   */
  case incompatible
  /**
   * Invalid reuse of reader locktable slot, e.g. read-transaction already run for current thread
   *
   * - Tag: MDBXError.badReadSlot
   */
  case badReadSlot
  /**
   * Transaction is not valid for requested operation, e.g. had errored and be must aborted, has a child, or is invalid
   *
   * - Tag: MDBXError.badTransaction
   */
  case badTransaction
  /**
   * Invalid size or alignment of key or data for target database, either invalid subDB name
   *
   * - Tag: MDBXError.badValSize
   */
  case badValSize
  /**
   * The specified DBI-handle is invalid or changed by another thread/transaction
   *
   * - Tag: MDBXError.badDatabase
   */
  case badDatabase
  /**
   * Unexpected internal error, transaction should be aborted
   *
   * - Tag: MDBXError.problem
   */
  case problem
  /**
   * The last LMDB-compatible defined error code
   *
   * - Tag: MDBXError.lastLMDBErrorCode
   */
  case lastLMDBErrorCode
  /**
   * Another write transaction is running or environment is already used while opening with MDBX_EXCLUSIVE flag
   *
   * - Tag: MDBXError.busy
   */
  case busy
  /**
   * The first of MDBX-added error codes
   *
   * - Tag: MDBXError.firstAddedErrorCode
   */
  case firstAddedErrorCode
  /**
   * The specified key has more than one associated value
   *
   * - Tag: MDBXError.multipleValues
   */
  case multipleValues
  /**
   * Bad signature of a runtime object(s)
   *
   * This can mean:
   * - memory corruption or double-free;
   * - ABI version mismatch (rare case);
   *
   * - Tag: MDBXError.badSignature
   */
  case badSignature
  /**
   * Database should be recovered, but this could NOT be done for now since it opened in read-only mode
   *
   * - Tag: MDBXError.wannaRecovery
   */
  case wannaRecovery
  /**
   * The given key value is mismatched to the current cursor position
   *
   * - Tag: MDBXError.keyMismatch
   */
  case keyMismatch
  /**
   * Database is too large for current system, e.g. could NOT be mapped into RAM.
   *
   * - Tag: MDBXError.tooLarge
   */
  case tooLarge
  /**
   * A thread has attempted to use a not owned object, e.g. a transaction that started by another thread.
   *
   * - Tag: MDBXError.threadMismatch
   */
  case threadMismatch
  /**
   * Overlapping read and write transactions for the current thread
   *
   * - Tag: MDBXError.transactionsOverlapping
   */
  case transactionsOverlapping
  case lastAddedErrorCode
  /**
   * Environment should be created first
   *
   * - Tag: MDBXError.notCreated
   */
  case notCreated
  /**
   * Environment was already created
   *
   * - Tag: MDBXError.alreadyCreated
   */
  case alreadyCreated
  /**
   * Attempt of double-opening of environment
   * 
   * - Tag: MDBXError.alreadyOpened
   */
  case alreadyOpened
  case ENODATA
  case EINVAL
  case EACCESS
  case ENOMEM
  case EROFS
  case ENOSYS
  case EIO
  case EPERM
  case EINTR
  case ENOFILE
  case EREMOTE
  
  public var code: Int32 {
    switch self {
    case .keyExist:                 return libmdbx.MDBX_KEYEXIST.rawValue
    case .firstLMDBErrorCode:       return libmdbx.MDBX_FIRST_LMDB_ERRCODE.rawValue
    case .notFound:                 return libmdbx.MDBX_NOTFOUND.rawValue
    case .pageNotFound:             return libmdbx.MDBX_PAGE_NOTFOUND.rawValue
    case .corrupted:                return libmdbx.MDBX_CORRUPTED.rawValue
    case .panic:                    return libmdbx.MDBX_PANIC.rawValue
    case .versionMismatch:          return libmdbx.MDBX_VERSION_MISMATCH.rawValue
    case .invalid:                  return libmdbx.MDBX_INVALID.rawValue
    case .mapFull:                  return libmdbx.MDBX_MAP_FULL.rawValue
    case .dbsFull:                  return libmdbx.MDBX_DBS_FULL.rawValue
    case .readersFull:              return libmdbx.MDBX_READERS_FULL.rawValue
    case .txnFull:                  return libmdbx.MDBX_TXN_FULL.rawValue
    case .cursorFull:               return libmdbx.MDBX_CURSOR_FULL.rawValue
    case .pageFull:                 return libmdbx.MDBX_PAGE_FULL.rawValue
    case .unableExtendMapsize:      return libmdbx.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue
    case .incompatible:             return libmdbx.MDBX_INCOMPATIBLE.rawValue
    case .badReadSlot:              return libmdbx.MDBX_BAD_RSLOT.rawValue
    case .badTransaction:           return libmdbx.MDBX_BAD_TXN.rawValue
    case .badValSize:               return libmdbx.MDBX_BAD_VALSIZE.rawValue
    case .badDatabase:              return libmdbx.MDBX_BAD_DBI.rawValue
    case .problem:                  return libmdbx.MDBX_PROBLEM.rawValue
    case .lastLMDBErrorCode:        return libmdbx.MDBX_LAST_LMDB_ERRCODE.rawValue
    case .busy:                     return libmdbx.MDBX_BUSY.rawValue
    case .firstAddedErrorCode:      return libmdbx.MDBX_FIRST_ADDED_ERRCODE.rawValue
    case .multipleValues:           return libmdbx.MDBX_EMULTIVAL.rawValue
    case .badSignature:             return libmdbx.MDBX_EBADSIGN.rawValue
    case .wannaRecovery:            return libmdbx.MDBX_WANNA_RECOVERY.rawValue
    case .keyMismatch:              return libmdbx.MDBX_EKEYMISMATCH.rawValue
    case .tooLarge:                 return libmdbx.MDBX_TOO_LARGE.rawValue
    case .threadMismatch:           return libmdbx.MDBX_THREAD_MISMATCH.rawValue
    case .transactionsOverlapping:  return libmdbx.MDBX_TXN_OVERLAPPING.rawValue
    case .lastAddedErrorCode:       return libmdbx.MDBX_LAST_ADDED_ERRCODE.rawValue
    case .notCreated:               return -30414
    case .alreadyOpened:            return -30413
    case .alreadyCreated:           return -30412
    case .ENODATA:                  return libmdbx.MDBX_ENODATA.rawValue
    case .EINVAL:                   return libmdbx.MDBX_EINVAL.rawValue
    case .EACCESS:                  return libmdbx.MDBX_EACCESS.rawValue
    case .ENOMEM:                   return libmdbx.MDBX_ENOMEM.rawValue
    case .EROFS:                    return libmdbx.MDBX_EROFS.rawValue
    case .ENOSYS:                   return libmdbx.MDBX_ENOSYS.rawValue
    case .EIO:                      return libmdbx.MDBX_EIO.rawValue
    case .EPERM:                    return libmdbx.MDBX_EPERM.rawValue
    case .EINTR:                    return libmdbx.MDBX_EINTR.rawValue
    case .ENOFILE:                  return libmdbx.MDBX_ENOFILE.rawValue
    case .EREMOTE:                  return libmdbx.MDBX_EREMOTE.rawValue
    }
  }
  
  public var errorDescription: String? {
    return String(cString: mdbx_strerror(self.code))
  }
}
