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
    case libmdbx_ios.MDBX_KEYEXIST.rawValue:                  self = .KEYEXIST
    case libmdbx_ios.MDBX_FIRST_LMDB_ERRCODE.rawValue:        self = .FIRST_LMDB_ERRCODE
    case libmdbx_ios.MDBX_NOTFOUND.rawValue:                  self = .NOTFOUND
    case libmdbx_ios.MDBX_PAGE_NOTFOUND.rawValue:             self = .PAGE_NOTFOUND
    case libmdbx_ios.MDBX_CORRUPTED.rawValue:                 self = .CORRUPTED
    case libmdbx_ios.MDBX_PANIC.rawValue:                     self = .PANIC
    case libmdbx_ios.MDBX_VERSION_MISMATCH.rawValue:          self = .VERSION_MISMATCH
    case libmdbx_ios.MDBX_INVALID.rawValue:                   self = .INVALID
    case libmdbx_ios.MDBX_MAP_FULL.rawValue:                  self = .MAP_FULL
    case libmdbx_ios.MDBX_DBS_FULL.rawValue:                  self = .DBS_FULL
    case libmdbx_ios.MDBX_READERS_FULL.rawValue:              self = .READERS_FULL
    case libmdbx_ios.MDBX_TXN_FULL.rawValue:                  self = .TXN_FULL
    case libmdbx_ios.MDBX_CURSOR_FULL.rawValue:               self = .CURSOR_FULL
    case libmdbx_ios.MDBX_PAGE_FULL.rawValue:                 self = .PAGE_FULL
    case libmdbx_ios.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue:     self = .UNABLE_EXTEND_MAPSIZE
    case libmdbx_ios.MDBX_INCOMPATIBLE.rawValue:              self = .INCOMPATIBLE
    case libmdbx_ios.MDBX_BAD_RSLOT.rawValue:                 self = .BAD_RSLOT
    case libmdbx_ios.MDBX_BAD_TXN.rawValue:                   self = .BAD_TXN
    case libmdbx_ios.MDBX_BAD_VALSIZE.rawValue:               self = .BAD_VALSIZE
    case libmdbx_ios.MDBX_BAD_DBI.rawValue:                   self = .BAD_DBI
    case libmdbx_ios.MDBX_PROBLEM.rawValue:                   self = .PROBLEM
    case libmdbx_ios.MDBX_LAST_LMDB_ERRCODE.rawValue:         self = .LAST_LMDB_ERRCODE
    case libmdbx_ios.MDBX_BUSY.rawValue:                      self = .BUSY
    case libmdbx_ios.MDBX_FIRST_ADDED_ERRCODE.rawValue:       self = .FIRST_ADDED_ERRCODE
    case libmdbx_ios.MDBX_EMULTIVAL.rawValue:                 self = .EMULTIVAL
    case libmdbx_ios.MDBX_EBADSIGN.rawValue:                  self = .EBADSIGN
    case libmdbx_ios.MDBX_WANNA_RECOVERY.rawValue:            self = .WANNA_RECOVERY
    case libmdbx_ios.MDBX_EKEYMISMATCH.rawValue:              self = .EKEYMISMATCH
    case libmdbx_ios.MDBX_TOO_LARGE.rawValue:                 self = .TOO_LARGE
    case libmdbx_ios.MDBX_THREAD_MISMATCH.rawValue:           self = .THREAD_MISMATCH
    case libmdbx_ios.MDBX_TXN_OVERLAPPING.rawValue:           self = .TXN_OVERLAPPING
    case libmdbx_ios.MDBX_LAST_ADDED_ERRCODE.rawValue:        self = .LAST_ADDED_ERRCODE
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
  
  /// key/                          data pair already exists
  case KEYEXIST
  /// The first LMDB-compatible defined error code
  case FIRST_LMDB_ERRCODE
  /// key/data pair not found (EOF)
  case NOTFOUND
  /// Requested page not found - this usually indicates corruption
  case PAGE_NOTFOUND
  /// Database is corrupted (page was wrong type and so on)
  case CORRUPTED
  /// Environment had fatal error, i.e. update of meta page failed and so on.
  case PANIC
  /// DB file version mismatch with libmdbx
  case VERSION_MISMATCH
  /// File is not a valid MDBX file
  case INVALID
  /// Environment mapsize reached
  case MAP_FULL
  /// Environment maxdbs reached
  case DBS_FULL
  /// Environment maxreaders reached
  case READERS_FULL
  /// Transaction has too many dirty pages, i.e transaction too big
  case TXN_FULL
  /// Cursor stack too deep - this usually indicates corruption, i.e branch-pages loop
  case CURSOR_FULL
  /// Page has not enough space - internal error
  case PAGE_FULL
  /// Database engine was unable to extend mapping, e.g. since address space is unavailable or busy. This can mean:
  ///
  /// - Database size extended by other process beyond to environment mapsize and engine was unable to extend mapping while starting read transaction. Environment should be reopened to continue.
  /// - Engine was unable to extend mapping during write transaction or explicit call of mdbx_env_set_geometry().
  case UNABLE_EXTEND_MAPSIZE
  /// Environment or database is not compatible with the requested operation or the specified flags. This can mean:
  ///
  /// - The operation expects an MDBX_DUPSORT / MDBX_DUPFIXED database.
  /// - Opening a named DB when the unnamed DB has MDBX_DUPSORT / MDBX_INTEGERKEY.
  /// - Accessing a data record as a database, or vice versa.
  /// - The database was dropped and recreated with different flags.
  case INCOMPATIBLE
  /// Invalid reuse of reader locktable slot, e.g. read-transaction already run for current thread
  case BAD_RSLOT
  /// Transaction is not valid for requested operation, e.g. had errored and be must aborted, has a child, or is invalid
  case BAD_TXN
  /// Invalid size or alignment of key or data for target database, either invalid subDB name
  case BAD_VALSIZE
  /// The specified DBI-handle is invalid or changed by another thread/transaction
  case BAD_DBI
  /// Unexpected internal error, transaction should be aborted
  case PROBLEM
  /// The last LMDB-compatible defined error code
  case LAST_LMDB_ERRCODE
  /// Another write transaction is running or environment is already used while opening with MDBX_EXCLUSIVE flag
  case BUSY
  /// The first of MDBX-added error codes
  case FIRST_ADDED_ERRCODE
  /// The specified key has more than one associated value
  case EMULTIVAL
  /// Bad signature of a runtime object(s)
  ///
  /// This can mean:
  /// - memory corruption or double-free;
  /// - ABI version mismatch (rare case);
  case EBADSIGN
  /// Database should be recovered, but this could NOT be done for now since it opened in read-only mode
  case WANNA_RECOVERY
  /// The given key value is mismatched to the current cursor position
  case EKEYMISMATCH
  /// Database is too large for current system, e.g. could NOT be mapped into RAM.
  case TOO_LARGE
  /// A thread has attempted to use a not owned object, e.g. a transaction that started by another thread.
  case THREAD_MISMATCH
  /// Overlapping read and write transactions for the current thread
  case TXN_OVERLAPPING
  case LAST_ADDED_ERRCODE
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
    case .KEYEXIST:                 return libmdbx_ios.MDBX_KEYEXIST.rawValue
    case .FIRST_LMDB_ERRCODE:       return libmdbx_ios.MDBX_FIRST_LMDB_ERRCODE.rawValue
    case .NOTFOUND:                 return libmdbx_ios.MDBX_NOTFOUND.rawValue
    case .PAGE_NOTFOUND:            return libmdbx_ios.MDBX_PAGE_NOTFOUND.rawValue
    case .CORRUPTED:                return libmdbx_ios.MDBX_CORRUPTED.rawValue
    case .PANIC:                    return libmdbx_ios.MDBX_PANIC.rawValue
    case .VERSION_MISMATCH:         return libmdbx_ios.MDBX_VERSION_MISMATCH.rawValue
    case .INVALID:                  return libmdbx_ios.MDBX_INVALID.rawValue
    case .MAP_FULL:                 return libmdbx_ios.MDBX_MAP_FULL.rawValue
    case .DBS_FULL:                 return libmdbx_ios.MDBX_DBS_FULL.rawValue
    case .READERS_FULL:             return libmdbx_ios.MDBX_READERS_FULL.rawValue
    case .TXN_FULL:                 return libmdbx_ios.MDBX_TXN_FULL.rawValue
    case .CURSOR_FULL:              return libmdbx_ios.MDBX_CURSOR_FULL.rawValue
    case .PAGE_FULL:                return libmdbx_ios.MDBX_PAGE_FULL.rawValue
    case .UNABLE_EXTEND_MAPSIZE:    return libmdbx_ios.MDBX_UNABLE_EXTEND_MAPSIZE.rawValue
    case .INCOMPATIBLE:             return libmdbx_ios.MDBX_INCOMPATIBLE.rawValue
    case .BAD_RSLOT:                return libmdbx_ios.MDBX_BAD_RSLOT.rawValue
    case .BAD_TXN:                  return libmdbx_ios.MDBX_BAD_TXN.rawValue
    case .BAD_VALSIZE:              return libmdbx_ios.MDBX_BAD_VALSIZE.rawValue
    case .BAD_DBI:                  return libmdbx_ios.MDBX_BAD_DBI.rawValue
    case .PROBLEM:                  return libmdbx_ios.MDBX_PROBLEM.rawValue
    case .LAST_LMDB_ERRCODE:        return libmdbx_ios.MDBX_LAST_LMDB_ERRCODE.rawValue
    case .BUSY:                     return libmdbx_ios.MDBX_BUSY.rawValue
    case .FIRST_ADDED_ERRCODE:      return libmdbx_ios.MDBX_FIRST_ADDED_ERRCODE.rawValue
    case .EMULTIVAL:                return libmdbx_ios.MDBX_EMULTIVAL.rawValue
    case .EBADSIGN:                 return libmdbx_ios.MDBX_EBADSIGN.rawValue
    case .WANNA_RECOVERY:           return libmdbx_ios.MDBX_WANNA_RECOVERY.rawValue
    case .EKEYMISMATCH:             return libmdbx_ios.MDBX_EKEYMISMATCH.rawValue
    case .TOO_LARGE:                return libmdbx_ios.MDBX_TOO_LARGE.rawValue
    case .THREAD_MISMATCH:          return libmdbx_ios.MDBX_THREAD_MISMATCH.rawValue
    case .TXN_OVERLAPPING:          return libmdbx_ios.MDBX_TXN_OVERLAPPING.rawValue
    case .LAST_ADDED_ERRCODE:       return libmdbx_ios.MDBX_LAST_ADDED_ERRCODE.rawValue
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
