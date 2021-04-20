//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/15/21.
//

import Foundation
import libmdbx_ios

struct MDBXDatabaseFlags: OptionSet {
  let rawValue: UInt32
  
  static let defaults = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_DB_DEFAULTS.rawValue)
  
  /** Use reverse string keys */
  static let reverseKey = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_REVERSEKEY.rawValue)
  
  /** Use sorted duplicates, i.e. allow multi-values */
  static let dupSort = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_DUPSORT.rawValue)
  
  /** Numeric keys in native byte order either uint32_t or uint64_t. The keys
  * must all be of the same size and must be aligned while passing as
  * arguments. */
  static let integerKey = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_INTEGERKEY.rawValue)
  
  /** With \ref MDBX_DUPSORT; sorted dup items have fixed size */
  static let dupFixed = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_DUPFIXED.rawValue)
  
  /** With \ref MDBX_DUPSORT and with \ref MDBX_DUPFIXED; dups are fixed size
  * \ref MDBX_INTEGERKEY -style integers. The data values must all be of the
  * same size and must be aligned while passing as arguments. */
  static let integerDup = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_INTEGERDUP.rawValue)
  
  /** With \ref MDBX_DUPSORT; use reverse string comparison */
  static let reverseDup = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_REVERSEDUP.rawValue)
  
  /** Create DB if not already existing */
  static let create = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_CREATE.rawValue)
  
  /** Opens an existing sub-database created with unknown flags.
   *
   * The `MDBX_DB_ACCEDE` flag is intend to open a existing sub-database which
   * was created with unknown flags (\ref MDBX_REVERSEKEY, \ref MDBX_DUPSORT,
   * \ref MDBX_INTEGERKEY, \ref MDBX_DUPFIXED, \ref MDBX_INTEGERDUP and
   * \ref MDBX_REVERSEDUP).
   *
   * In such cases, instead of returning the \ref MDBX_INCOMPATIBLE error, the
   * sub-database will be opened with flags which it was created, and then an
   * application could determine the actual flags by \ref mdbx_dbi_flags(). */
  static let accede = MDBXDatabaseFlags(rawValue: libmdbx_ios.MDBX_ACCEDE.rawValue)
}

internal extension MDBXDatabaseFlags {
  var MDBX_db_flags_t: MDBX_db_flags_t {
    libmdbx_ios.MDBX_db_flags_t(self.rawValue)
  }
}