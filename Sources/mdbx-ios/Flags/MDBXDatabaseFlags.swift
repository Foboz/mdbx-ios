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
  
  /**
   * Defaults database flags
   *
   * - Tag: MDBXDatabaseFlags.defaults
   */
  public static let defaults = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DB_DEFAULTS.rawValue)
  
  /**
   * Use reverse string keys
   *
   * - Tag: MDBXDatabaseFlags.reverseKey
   */
  public static let reverseKey = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_REVERSEKEY.rawValue)
  
  /**
   * Use sorted duplicates, i.e. allow multi-values
   *
   * - Tag: MDBXDatabaseFlags.dupSort
   */
  public static let dupSort = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DUPSORT.rawValue)
  
  /**
   * Numeric keys in native byte order either uint32_t or uint64_t. The keys
   * must all be of the same size and must be aligned while passing as
   * arguments.
   *
   * - Tag: MDBXDatabaseFlags.integerKey
   */
  public static let integerKey = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_INTEGERKEY.rawValue)
  
  /**
   * With [dupSort](x-source-tag://[MDBXDatabaseFlags.dupSort]) sorted dup items have fixed size
   *
   * - Tag: MDBXDatabaseFlags.dupFixed
   */
  public static let dupFixed = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_DUPFIXED.rawValue)
  
  /**
   * With [dupSort](x-source-tag://[MDBXDatabaseFlags.dupSort]) and with [dupFixed](x-source-tag://[MDBXDatabaseFlags.dupFixed]) dups are fixed size
   * [integerKey](x-source-tag://[MDBXDatabaseFlags.integerKey])-style integers. The data values must all be of the
   * same size and must be aligned while passing as arguments.
   *
   * - Tag: MDBXDatabaseFlags.integerDup
   */
  public static let integerDup = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_INTEGERDUP.rawValue)
  
  /**
   * With [dupSort](x-source-tag://[MDBXDatabaseFlags.dupSort]) use reverse string comparison
   *
   * - Tag: MDBXDatabaseFlags.reverseDup
   */
  public static let reverseDup = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_REVERSEDUP.rawValue)
  
  /**
   * Create DB if not already existing
   *
   * - Tag: MDBXDatabaseFlags.create
   */
  public static let create = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_CREATE.rawValue)
  
  /**
   * Opens an existing sub-database created with unknown flags.
   *
   * The [accede](x-source-tag://[MDBXDatabaseFlags.accede]) flag is intend to open a existing sub-database which
   * was created with unknown flags ([reverseKey](x-source-tag://[MDBXDatabaseFlags.reverseKey]), [dupSort](x-source-tag://[MDBXDatabaseFlags.dupSort]),
   * [integerKey](x-source-tag://[MDBXDatabaseFlags.integerKey]), [dupFixed](x-source-tag://[MDBXDatabaseFlags.dupFixed]),
   * [integerDup](x-source-tag://[MDBXDatabaseFlags.integerDup]) and [reverseDup](x-source-tag://[MDBXDatabaseFlags.reverseDup])).
   *
   * In such cases, instead of returning the [incompatible](x-source-tag://[MDBXError.incompatible]) error, the
   * sub-database will be opened with flags which it was created, and then an
   * application could determine the actual flags by [databaseFlags(transaction:database:flags:)](x-source-tag://[MDBX+Meta.databaseFlags]).
   *
   * - Tag: MDBXDatabaseFlags.accede
   */
  public static let accede = MDBXDatabaseFlags(rawValue: libmdbx.MDBX_ACCEDE.rawValue)
}

internal extension MDBXDatabaseFlags {
  var MDBX_db_flags_t: MDBX_db_flags_t {
    libmdbx.MDBX_db_flags_t(self.rawValue)
  }
}
