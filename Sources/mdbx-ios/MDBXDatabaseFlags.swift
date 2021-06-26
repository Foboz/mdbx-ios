//
//  MDBXDatabaseFlags.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/15/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

public struct MDBXDatabaseFlags: OptionSet {
  public let rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  public static let defaults = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DB_DEFAULTS.rawValue)
  
  /** Use reverse string keys */
  public static let reverseKey = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_REVERSEKEY.rawValue)
  
  /** Use sorted duplicates, i.e. allow multi-values */
  public static let dupSort = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DUPSORT.rawValue)
  
  /** Numeric keys in native byte order either uint32_t or uint64_t. The keys
  * must all be of the same size and must be aligned while passing as
  * arguments. */
  public static let integerKey = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_INTEGERKEY.rawValue)
  
  /** With \ref MDBX_DUPSORT; sorted dup items have fixed size */
  public static let dupFixed = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DUPFIXED.rawValue)
  
  /** With \ref MDBX_DUPSORT and with \ref MDBX_DUPFIXED; dups are fixed size
  * \ref MDBX_INTEGERKEY -style integers. The data values must all be of the
  * same size and must be aligned while passing as arguments. */
  public static let integerDup = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_INTEGERDUP.rawValue)
  
  /** With \ref MDBX_DUPSORT; use reverse string comparison */
  public static let reverseDup = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_REVERSEDUP.rawValue)
  
  /** Create DB if not already existing */
  public static let create = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_CREATE.rawValue)
  
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
  public static let accede = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_ACCEDE.rawValue)
}

internal extension MDBXDatabaseFlags {
  var MDBX_db_flags_t: MDBX_db_flags_t {
    libmdbx.MDBX_db_flags_t(self.rawValue)
  }
}
