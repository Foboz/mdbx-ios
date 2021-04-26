//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/17/21.
//

import Foundation

import libmdbx_ios

struct MDBXPutFlags: OptionSet {
  let rawValue: UInt32
  
  /** Upsertion by default (without any other flags) */
  static let upsert = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_UPSERT.rawValue)

  /** For insertion: Don't write if the key already exists. */
  static let noOverWrite = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_NOOVERWRITE.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * For upsertion: don't write if the key-value pair already exist.
   * For deletion: remove all values for key. */
  static let noDupData = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_NODUPDATA.rawValue)
  
  /** For upsertion: overwrite the current key/data pair.
   * MDBX allows this flag for \ref mdbx_put() for explicit overwrite/update
   * without insertion.
   * For deletion: remove only single entry at the current cursor position. */
  static let current = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_CURRENT.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * For deletion: remove all multi-values (aka duplicates) for given key.
   * For upsertion: replace all multi-values for given key with a new one. */
  static let allDups = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_ALLDUPS.rawValue)
  
  /** For upsertion: Just reserve space for data, don't copy it.
   * Return a pointer to the reserved space. */
  static let reserve = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_RESERVE.rawValue)

  /** Data is being appended.
   * Don't split full pages, continue on a new instead. */
  static let append = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_APPEND.rawValue)
  
  /** Has effect only for \ref MDBX_DUPSORT databases.
   * Duplicate data is being appended.
   * Don't split full pages, continue on a new instead. */
  static let appendDup = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_APPENDDUP.rawValue)
  
  /** Only for \ref MDBX_DUPFIXED.
   * Store multiple data items in one call. */
  static let multiple = MDBXPutFlags(rawValue: libmdbx_ios.MDBX_MULTIPLE.rawValue)
}

internal extension MDBXPutFlags {
  var MDBX_put_flags_t: MDBX_put_flags_t {
    libmdbx_ios.MDBX_put_flags_t(self.rawValue)
  }
}
