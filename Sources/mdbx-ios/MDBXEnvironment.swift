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
  internal var _env: MDBX_env!
  init() {
  }
  
  func open(path: String) {
    mdbx_env_open(_env, path.cString(using: .utf8), <#T##flags: MDBX_env_flags_t##MDBX_env_flags_t#>, <#T##mode: mdbx_mode_t##mdbx_mode_t#>)
    
//    LIBMDBX_API int mdbx_env_open  (  MDBX_env *   env,
//    const char *   pathname,
//    MDBX_env_flags_t   flags,
//    mdbx_mode_t   mode
//    )
  }
  
  /// Create an MDBX environment instance.
  /// This function allocates memory for a MDBX_env structure. To release the allocated memory and discard the handle, call mdbx_env_close(). Before the handle may be used, it must be opened using mdbx_env_open().
  ///
  /// Various other options may also need to be set before opening the handle, e.g. mdbx_env_set_geometry(), mdbx_env_set_maxreaders(), mdbx_env_set_maxdbs(), depending on usage requirements.
  ///
  /// Throws
  /// - MDBXError

  func create() throws {
    let code = withUnsafeMutablePointer(to: &_env) { pointer in
      return mdbx_env_create(pointer)
    }
    guard code != 0, let error = MDBXError(code: code) else { return }
    throw error
  }
  
  func close() {
    
  }
  
  
  
//  LIBMDBX_API int   mdbx_env_create (MDBX_env **penv)
//     Create an MDBX environment instance. More...
//
//  LIBMDBX_API int   mdbx_env_open (MDBX_env *env, const char *pathname, MDBX_env_flags_t flags, mdbx_mode_t mode)
//     Open an environment instance. More...
//
//  LIBMDBX_API int   mdbx_env_close_ex (MDBX_env *env, bool dont_sync)
//     Close the environment and release the memory map. More...
//
//  int   mdbx_env_close (MDBX_env *env)
//     The shortcut to calling mdbx_env_close_ex() with the dont_sync=false argument. More...
}
