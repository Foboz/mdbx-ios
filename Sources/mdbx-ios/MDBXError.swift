//
//  File 2.swift
//  
//
//  Created by Mikhail Nikanorov on 4/7/21.
//

import Foundation
import libmdbx_ios

enum MDBXError: LocalizedError {
  init?(code: Int32) {
    switch code {
    case libmdbx_ios.MDBX_KEYEXIST.rawValue:                  self = .keyExist
    case libmdbx_ios.MDBX_FIRST_LMDB_ERRCODE.rawValue:        self = .firstLMDBErrorCode
    case libmdbx_ios.MDBX_NOTFOUND.rawValue:                  self = .notFound
    case libmdbx_ios.MDBX_PAGE_NOTFOUND.rawValue:             self = .pageNotFound
    case libmdbx_ios.MDBX_CORRUPTED.rawValue:                 self = .corrupted
    case libmdbx_ios.MDBX_PANIC.rawValue:                     self = .panic
    case libmdbx_ios.MDBX_VERSION_MISMATCH.rawValue:          self = .versionMismatch
    case libmdbx_ios.MDBX_INVALID.rawValue:                   self = .invalid
    case libmdbx_ios.MDBX_MAP_FULL.rawValue:                  self = .mapFull
    case libmdbx_ios.MDBX_DBS_FULL.rawValue:                  self = .dbsFull
    case libmdbx_ios.MDBX_READERS_FULL.rawValue:              self = .readersFull
    case libmdbx_ios.MDBX_TXN_FULL.rawValue:                  self = .txnFull
    case libmdbx_ios.MDBX_CURSOR_FULL.rawValue:               self = .cursorFull
    case libmdbx_ios.MDBX_PAGE_FULL.rawValue:                 self = .pageFull
    case libmdbx_ios.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue:     self = .unableExtendMapsize
    case libmdbx_ios.MDBX_INCOMPATIBLE.rawValue:              self = .incompatible
    case libmdbx_ios.MDBX_BAD_RSLOT.rawValue:                 self = .badReadSlot
    case libmdbx_ios.MDBX_BAD_TXN.rawValue:                   self = .badTransaction
    case libmdbx_ios.MDBX_BAD_VALSIZE.rawValue:               self = .badValSize
    case libmdbx_ios.MDBX_BAD_DBI.rawValue:                   self = .badDatabase
    case libmdbx_ios.MDBX_PROBLEM.rawValue:                   self = .problem
    case libmdbx_ios.MDBX_LAST_LMDB_ERRCODE.rawValue:         self = .lastLMDBErrorCode
    case libmdbx_ios.MDBX_BUSY.rawValue:                      self = .busy
    case libmdbx_ios.MDBX_FIRST_ADDED_ERRCODE.rawValue:       self = .firstAddedErrorCode
    case libmdbx_ios.MDBX_EMULTIVAL.rawValue:                 self = .multipleValues
    case libmdbx_ios.MDBX_EBADSIGN.rawValue:                  self = .badSignature
    case libmdbx_ios.MDBX_WANNA_RECOVERY.rawValue:            self = .wannaRecovery
    case libmdbx_ios.MDBX_EKEYMISMATCH.rawValue:              self = .keyMismatch
    case libmdbx_ios.MDBX_TOO_LARGE.rawValue:                 self = .tooLarge
    case libmdbx_ios.MDBX_THREAD_MISMATCH.rawValue:           self = .threadMismatch
    case libmdbx_ios.MDBX_TXN_OVERLAPPING.rawValue:           self = .transactionsOverlapping
    case libmdbx_ios.MDBX_LAST_ADDED_ERRCODE.rawValue:        self = .lastAddedErrorCode
    case libmdbx_ios.MDBX_ENODATA.rawValue:                   self = .ENODATA
    case libmdbx_ios.MDBX_EINVAL.rawValue:                    self = .EINVAL
    case libmdbx_ios.MDBX_EACCESS.rawValue:                   self = .EACCESS
    case libmdbx_ios.MDBX_ENOMEM.rawValue:                    self = .ENOMEM
    case libmdbx_ios.MDBX_EROFS.rawValue:                     self = .EROFS
    case libmdbx_ios.MDBX_ENOSYS.rawValue:                    self = .ENOSYS
    case libmdbx_ios.MDBX_EIO.rawValue:                       self = .EIO
    case libmdbx_ios.MDBX_EPERM.rawValue:                     self = .EPERM
    case libmdbx_ios.MDBX_EINTR.rawValue:                     self = .EINTR
    case libmdbx_ios.MDBX_ENOFILE.rawValue:                   self = .ENOFILE
    case libmdbx_ios.MDBX_EREMOTE.rawValue:                   self = .EREMOTE
    default: return nil
    }
  }
  
  /// key/data pair already exists
  case keyExist
  /// The first LMDB-compatible defined error code
  case firstLMDBErrorCode
  /// key/data pair not found (EOF)
  case notFound
  /// Requested page not found - this usually indicates corruption
  case pageNotFound
  /// Database is corrupted (page was wrong type and so on)
  case corrupted
  /// Environment had fatal error, i.e. update of meta page failed and so on.
  case panic
  /// DB file version mismatch with libmdbx
  case versionMismatch
  /// File is not a valid MDBX file
  case invalid
  /// Environment mapsize reached
  case mapFull
  /// Environment maxdbs reached
  case dbsFull
  /// Environment maxreaders reached
  case readersFull
  /// Transaction has too many dirty pages, i.e transaction too big
  case txnFull
  /// Cursor stack too deep - this usually indicates corruption, i.e branch-pages loop
  case cursorFull
  /// Page has not enough space - internal error
  case pageFull
  /// Database engine was unable to extend mapping, e.g. since address space is unavailable or busy. This can mean:
  ///
  /// - Database size extended by other process beyond to environment mapsize and engine was unable to extend mapping while starting read transaction. Environment should be reopened to continue.
  /// - Engine was unable to extend mapping during write transaction or explicit call of mdbx_env_set_geometry().
  case unableExtendMapsize
  /// Environment or database is not compatible with the requested operation or the specified flags. This can mean:
  ///
  /// - The operation expects an MDBX_DUPSORT / MDBX_DUPFIXED database.
  /// - Opening a named DB when the unnamed DB has MDBX_DUPSORT / MDBX_INTEGERKEY.
  /// - Accessing a data record as a database, or vice versa.
  /// - The database was dropped and recreated with different flags.
  case incompatible
  /// Invalid reuse of reader locktable slot, e.g. read-transaction already run for current thread
  case badReadSlot
  /// Transaction is not valid for requested operation, e.g. had errored and be must aborted, has a child, or is invalid
  case badTransaction
  /// Invalid size or alignment of key or data for target database, either invalid subDB name
  case badValSize
  /// The specified DBI-handle is invalid or changed by another thread/transaction
  case badDatabase
  /// Unexpected internal error, transaction should be aborted
  case problem
  /// The last LMDB-compatible defined error code
  case lastLMDBErrorCode
  /// Another write transaction is running or environment is already used while opening with MDBX_EXCLUSIVE flag
  case busy
  /// The first of MDBX-added error codes
  case firstAddedErrorCode
  /// The specified key has more than one associated value
  case multipleValues
  /// Bad signature of a runtime object(s)
  ///
  /// This can mean:
  /// - memory corruption or double-free;
  /// - ABI version mismatch (rare case);
  case badSignature
  /// Database should be recovered, but this could NOT be done for now since it opened in read-only mode
  case wannaRecovery
  /// The given key value is mismatched to the current cursor position
  case keyMismatch
  /// Database is too large for current system, e.g. could NOT be mapped into RAM.
  case tooLarge
  /// A thread has attempted to use a not owned object, e.g. a transaction that started by another thread.
  case threadMismatch
  /// Overlapping read and write transactions for the current thread
  case transactionsOverlapping
  case lastAddedErrorCode
  /// Environment should be created first
  case notCreated
  /// Environment was already created
  case alreadyCreated
  /// Attempt of double-opening of environment
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
  
  var code: Int32 {
    switch self {
    case .keyExist:                 return libmdbx_ios.MDBX_KEYEXIST.rawValue
    case .firstLMDBErrorCode:       return libmdbx_ios.MDBX_FIRST_LMDB_ERRCODE.rawValue
    case .notFound:                 return libmdbx_ios.MDBX_NOTFOUND.rawValue
    case .pageNotFound:             return libmdbx_ios.MDBX_PAGE_NOTFOUND.rawValue
    case .corrupted:                return libmdbx_ios.MDBX_CORRUPTED.rawValue
    case .panic:                    return libmdbx_ios.MDBX_PANIC.rawValue
    case .versionMismatch:          return libmdbx_ios.MDBX_VERSION_MISMATCH.rawValue
    case .invalid:                  return libmdbx_ios.MDBX_INVALID.rawValue
    case .mapFull:                  return libmdbx_ios.MDBX_MAP_FULL.rawValue
    case .dbsFull:                  return libmdbx_ios.MDBX_DBS_FULL.rawValue
    case .readersFull:              return libmdbx_ios.MDBX_READERS_FULL.rawValue
    case .txnFull:                  return libmdbx_ios.MDBX_TXN_FULL.rawValue
    case .cursorFull:               return libmdbx_ios.MDBX_CURSOR_FULL.rawValue
    case .pageFull:                 return libmdbx_ios.MDBX_PAGE_FULL.rawValue
    case .unableExtendMapsize:      return libmdbx_ios.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue
    case .incompatible:             return libmdbx_ios.MDBX_INCOMPATIBLE.rawValue
    case .badReadSlot:              return libmdbx_ios.MDBX_BAD_RSLOT.rawValue
    case .badTransaction:           return libmdbx_ios.MDBX_BAD_TXN.rawValue
    case .badValSize:               return libmdbx_ios.MDBX_BAD_VALSIZE.rawValue
    case .badDatabase:              return libmdbx_ios.MDBX_BAD_DBI.rawValue
    case .problem:                  return libmdbx_ios.MDBX_PROBLEM.rawValue
    case .lastLMDBErrorCode:        return libmdbx_ios.MDBX_LAST_LMDB_ERRCODE.rawValue
    case .busy:                     return libmdbx_ios.MDBX_BUSY.rawValue
    case .firstAddedErrorCode:      return libmdbx_ios.MDBX_FIRST_ADDED_ERRCODE.rawValue
    case .multipleValues:           return libmdbx_ios.MDBX_EMULTIVAL.rawValue
    case .badSignature:             return libmdbx_ios.MDBX_EBADSIGN.rawValue
    case .wannaRecovery:            return libmdbx_ios.MDBX_WANNA_RECOVERY.rawValue
    case .keyMismatch:              return libmdbx_ios.MDBX_EKEYMISMATCH.rawValue
    case .tooLarge:                 return libmdbx_ios.MDBX_TOO_LARGE.rawValue
    case .threadMismatch:           return libmdbx_ios.MDBX_THREAD_MISMATCH.rawValue
    case .transactionsOverlapping:  return libmdbx_ios.MDBX_TXN_OVERLAPPING.rawValue
    case .lastAddedErrorCode:       return libmdbx_ios.MDBX_LAST_ADDED_ERRCODE.rawValue
    case .notCreated:               return -30414
    case .alreadyOpened:            return -30413
    case .alreadyCreated:           return -30412
    case .ENODATA:                  return libmdbx_ios.MDBX_ENODATA.rawValue
    case .EINVAL:                   return libmdbx_ios.MDBX_EINVAL.rawValue
    case .EACCESS:                  return libmdbx_ios.MDBX_EACCESS.rawValue
    case .ENOMEM:                   return libmdbx_ios.MDBX_ENOMEM.rawValue
    case .EROFS:                    return libmdbx_ios.MDBX_EROFS.rawValue
    case .ENOSYS:                   return libmdbx_ios.MDBX_ENOSYS.rawValue
    case .EIO:                      return libmdbx_ios.MDBX_EIO.rawValue
    case .EPERM:                    return libmdbx_ios.MDBX_EPERM.rawValue
    case .EINTR:                    return libmdbx_ios.MDBX_EINTR.rawValue
    case .ENOFILE:                  return libmdbx_ios.MDBX_ENOFILE.rawValue
    case .EREMOTE:                  return libmdbx_ios.MDBX_EREMOTE.rawValue
    }
  }
  
  var errorDescription: String? {
    return String(cString: mdbx_strerror(self.code))
  }
}
