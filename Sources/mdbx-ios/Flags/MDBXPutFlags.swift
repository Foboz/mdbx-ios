//
//  MDBXPutFlags.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/17/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

public struct MDBXPutFlags: OptionSet {
  public let rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  /** Upsertion by default (without any other flags) */
  public static let upsert = MDBXPutFlags(rawValue: libmdbx.MDBX_UPSERT.rawValue)

  /** For insertion: Don't write if the key already exists. */
  public static let noOverWrite = MDBXPutFlags(rawValue: libmdbx.MDBX_NOOVERWRITE.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * For upsertion: don't write if the key-value pair already exist.
   * For deletion: remove all values for key. */
  public static let noDupData = MDBXPutFlags(rawValue: libmdbx.MDBX_NODUPDATA.rawValue)
  
  /** For upsertion: overwrite the current key/data pair.
   * MDBX allows this flag for \ref mdbx_put() for explicit overwrite/update
   * without insertion.
   * For deletion: remove only single entry at the current cursor position. */
  public static let current = MDBXPutFlags(rawValue: libmdbx.MDBX_CURRENT.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * For deletion: remove all multi-values (aka duplicates) for given key.
   * For upsertion: replace all multi-values for given key with a new one. */
  public static let allDups = MDBXPutFlags(rawValue: libmdbx.MDBX_ALLDUPS.rawValue)
  
  /** For upsertion: Just reserve space for data, don't copy it.
   * Return a pointer to the reserved space. */
  public static let reserve = MDBXPutFlags(rawValue: libmdbx.MDBX_RESERVE.rawValue)

  /** Data is being appended.
   * Don't split full pages, continue on a new instead. */
  public static let append = MDBXPutFlags(rawValue: libmdbx.MDBX_APPEND.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * Duplicate data is being appended.
   * Don't split full pages, continue on a new instead. */
  public static let appendDup = MDBXPutFlags(rawValue: libmdbx.MDBX_APPENDDUP.rawValue)
  
  /** Only for \ref MDBX_DUPFIXED.
   * Store multiple data items in one call. */
  public static let multiple = MDBXPutFlags(rawValue: libmdbx.MDBX_MULTIPLE.rawValue)
}

internal extension MDBXPutFlags {
  var MDBX_put_flags_t: MDBX_put_flags_t {
    libmdbx.MDBX_put_flags_t(self.rawValue)
  }
}
