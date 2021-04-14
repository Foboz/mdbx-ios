//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/7/21.
//

import Foundation
import libmdbx_ios

internal typealias MDBX_env = OpaquePointer

class MDBXEnvironment {
  internal enum MDBXEnvironmentState {
    case unknown
    case created
    case opened
  }
  
  internal var _env: MDBX_env!
  internal var _state: MDBXEnvironmentState = .unknown
  
  init() {}
  
  deinit {
    if _state == .opened {
      self.close()
    }
  }
  
  /**
   Create an MDBX environment instance.
   
   This function allocates memory for a \ref MDBX_env structure. To release
   the allocated memory and discard the handle, call \ref mdbx_env_close().
   Before the handle may be used, it must be opened using \ref mdbx_env_open().
   
   Various other options may also need to be set before opening the handle,
   e.g. \ref mdbx_env_set_geometry(), \ref mdbx_env_set_maxreaders(),
   \ref mdbx_env_set_maxdbs(), depending on usage requirements.
   
   - Throws:
      - alreadyCreated:
        If environment was alread opened
   */

  func create() throws {
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
   Open an environment instance.
   
   Indifferently this function will fails or not, the \ref mdbx_env_close() must
   be called later to discard the \ref MDBX_env handle and release associated
   resources.
   
   Flags set by mdbx_env_set_flags() are also used:
   - \ref MDBX_NOSUBDIR, \ref MDBX_RDONLY, \ref MDBX_EXCLUSIVE,
    \ref MDBX_WRITEMAP, \ref MDBX_NOTLS, \ref MDBX_NORDAHEAD,
    \ref MDBX_NOMEMINIT, \ref MDBX_COALESCE, \ref MDBX_LIFORECLAIM.
    See \ref env_flags section.
   
   - \ref MDBX_NOMETASYNC, \ref MDBX_SAFE_NOSYNC, \ref MDBX_UTTERLY_NOSYNC.
    See \ref sync_modes section.
   
   - Note:
    `MDB_NOLOCK` flag don't supported by MDBX, try use \ref MDBX_EXCLUSIVE as a replacement.
   
   - Note:
    MDBX don't allow to mix processes with different \ref MDBX_SAFE_NOSYNC flags on the same environment.
    In such case \ref MDBX_INCOMPATIBLE will be returned.
   
   If the database is already exist and parameters specified early by
   \ref mdbx_env_set_geometry() are incompatible (i.e. for instance, different
   page size) then \ref mdbx_env_open() will return \ref MDBX_INCOMPATIBLE
   error.
   
   - Parameters:
      - pathname:
        The pathname for the database or the directory in which
        the database files reside. In the case of directory it
        must already exist and be writable.
   
      - flags:
        Special options for this environment. This parameter
        must be set to 0 or by bitwise OR'ing together one
        or more of the values described above in the
        \ref env_flags and \ref sync_modes sections.
   
      - mode:
        The UNIX permissions to set on created files.
        Zero value means to open existing, but do not create.
   
   - Throws:
      - MDBX_VERSION_MISMATCH:
        The version of the MDBX library doesn't match the version that created the database environment.
      - MDBX_INVALID:
        The environment file headers are corrupted.
      - MDBX_ENOENT:
        The directory specified by the path parameter doesn't exist.
      - MDBX_EACCES:
        The user didn't have permission to access the environment files.
      - MDBX_EAGAIN:
        The environment was locked by another process.
      - MDBX_BUSY:
        The \ref MDBX_EXCLUSIVE flag was specified and the environment is in use by another process,
        or the current process tries to open environment more than once.
      - MDBX_INCOMPATIBLE:
        Environment is already opened by another process, but with different set of \ref MDBX_SAFE_NOSYNC,
        \ref MDBX_UTTERLY_NOSYNC flags. Or if the database is already exist and parameters
        specified early by \ref mdbx_env_set_geometry() are incompatible (i.e. different pagesize, etc).
      - MDBX_WANNA_RECOVERY:
        The \ref MDBX_RDONLY flag was specified but read-write access is required to rollback
        inconsistent state after a system crash.
      - MDBX_TOO_LARGE:
        Database is too large for this process, i.e. 32-bit process tries to open >4Gb database.
   */
  func open(pathname: String, flags: MDBXEnvironmentFlags, mode: MDBXEnvironmentMode) throws {
    guard self._state == .created else {
      if self._state == .unknown { throw MDBXError.notCreated }
      else { throw MDBXError.alreadyOpened }
    }
    let code = mdbx_env_open(_env, pathname.cString(using: .utf8), flags.MDBX_env_flags_t, mode.rawValue)
    self._state = .opened
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  /**
   Close the environment and release the memory map.
   
   Only a single thread may call this function. All transactions, databases,
   and cursors must already be closed before calling this function. Attempts
   to use any such handles after calling this function will cause a `SIGSEGV`.
   The environment handle will be freed and must not be used again after this
   call.
   
   - Parameters:
      - dontSync:
        A dont'sync flag, if non-zero the last checkpoint will be kept "as is" and may be still "weak" in the
        \ref MDBX_SAFE_NOSYNC or \ref MDBX_UTTERLY_NOSYNC modes. Such "weak" checkpoint will be ignored on
        opening next time, and transactions since the last non-weak checkpoint (meta-page update) will rolledback
        for consistency guarantee.
   
   - Throws:
      - MDBX_BUSY
        The write transaction is running by other thread, in such case \ref MDBX_env instance has NOT be destroyed
        not released!
        - Note:
          If any OTHER error code was returned then given MDBX_env instance has been destroyed and released.
   
      - MDBX_EBADSIGN:  Environment handle already closed or not valid,
        i.e. \ref mdbx_env_close() was already called for the `env` or was not created by \ref mdbx_env_create().
   
      - MDBX_PANIC:
        If \ref mdbx_env_close_ex() was called in the child process after `fork()`. In this case \ref MDBX_PANIC
        is expected, i.e. \ref MDBX_env instance was freed in proper manner.
   
      - MDBX_EIO:
        An error occurred during synchronization.
   */
  func close(_ dontSync: Bool = false) {
    guard self._state == .opened else {
      return
    }
    mdbx_env_close_ex(_env, dontSync)
    self._state = .unknown
  }
}
