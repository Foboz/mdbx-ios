//
//  MDBXCursorOperation.swift
//  mdbx-ios
//
//  Created by Nail Galiaskarov on 4/19/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import libmdbx

/** \brief Cursor operations
 * \ingroup c_cursors
 * This is the set of all operations for retrieving data using a cursor.
 * \see mdbx_cursor_get() */

public struct MDBXCursorOperations: OptionSet {
  public let rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  /** Position at first key/data item */
  public static let first = MDBXCursorOperations(rawValue: libmdbx.MDBX_FIRST.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at first data item of current key. */
  public static let firstDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_FIRST_DUP.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at key/data pair. */
  public static let getBoth = MDBXCursorOperations(rawValue: libmdbx.MDBX_GET_BOTH.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at given key and at first data greater
   * than or equal to specified data. */
  public static let getBothRange = MDBXCursorOperations(rawValue: libmdbx.MDBX_GET_BOTH_RANGE.rawValue)
  
  /** Return key/data at current cursor position */
  public static let getCurrent = MDBXCursorOperations(rawValue: libmdbx.MDBX_GET_CURRENT.rawValue)
  
  /** \ref MDBX_DUPFIXED -only: Return up to a page of duplicate data items
   * from current cursor position. Move cursor to prepare
   * for \ref MDBX_NEXT_MULTIPLE. */
  public static let getMultiple = MDBXCursorOperations(rawValue: libmdbx.MDBX_GET_MULTIPLE.rawValue)
  
  /** Position at last key/data item */
  public static let last = MDBXCursorOperations(rawValue: libmdbx.MDBX_LAST.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at last data item of current key. */
  public static let lastDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_LAST_DUP.rawValue)
  
  /** Position at next data item */
  public static let next = MDBXCursorOperations(rawValue: libmdbx.MDBX_NEXT.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at next data item of current key. */
  public static let nextDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_NEXT_DUP.rawValue)
  
  /** \ref MDBX_DUPFIXED -only: Return up to a page of duplicate data items
   * from next cursor position. Move cursor to prepare
   * for `MDBX_NEXT_MULTIPLE`. */
  public static let nextMultiple = MDBXCursorOperations(rawValue: libmdbx.MDBX_NEXT_MULTIPLE.rawValue)
  
  /** Position at first data item of next key */
  public static let nextNoDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_NEXT_NODUP.rawValue)
  
  /** Position at previous data item */
  public static let prev = MDBXCursorOperations(rawValue: libmdbx.MDBX_PREV.rawValue)
  
  /** \ref MDBX_DUPSORT -only: Position at previous data item of current key. */
  public static let prevDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_PREV_DUP.rawValue)
  
  /** Position at last data item of previous key */
  public static let prevNoDup = MDBXCursorOperations(rawValue: libmdbx.MDBX_PREV_NODUP.rawValue)
  
  /** Position at specified key */
  public static let set = MDBXCursorOperations(rawValue: libmdbx.MDBX_SET.rawValue)
  
  /** Position at specified key, return both key and data */
  public static let setKey = MDBXCursorOperations(rawValue: libmdbx.MDBX_SET_KEY.rawValue)
  
  /** Position at first key greater than or equal to specified key. */
  public static let setRange = MDBXCursorOperations(rawValue: libmdbx.MDBX_SET_RANGE.rawValue)
  
  /** \ref MDBX_DUPFIXED -only: Position at previous page and return up to
   * a page of duplicate data items. */
  public static let prevMultiple = MDBXCursorOperations(rawValue: libmdbx.MDBX_PREV_MULTIPLE.rawValue)
  
  /** Position at first key-value pair greater than or equal to specified,
   * return both key and data, and the return code depends on a exact match.
   *
   * For non DUPSORT-ed collections this work the same to \ref MDBX_SET_RANGE,
   * but returns \ref MDBX_SUCCESS if key found exactly and
   * \ref MDBX_RESULT_TRUE if greater key was found.
   *
   * For DUPSORT-ed a data value is taken into account for duplicates,
   * i.e. for a pairs/tuples of a key and an each data value of duplicates.
   * Returns \ref MDBX_SUCCESS if key-value pair found exactly and
   * \ref MDBX_RESULT_TRUE if the next pair was returned. */
  public static let setLowerBound = MDBXCursorOperations(rawValue: libmdbx.MDBX_SET_LOWERBOUND.rawValue)
  
  /** Positions cursor at first key-value pair greater than specified,
   * return both key and data, and the return code depends on whether a
   * upper-bound was found.
   *
   * For non DUPSORT-ed collections this work the same to \ref MDBX_SET_RANGE,
   * but returns \ref MDBX_SUCCESS if the greater key was found or
   * \ref MDBX_NOTFOUND otherwise.
   *
   * For DUPSORT-ed a data value is taken into account for duplicates,
   * i.e. for a pairs/tuples of a key and an each data value of duplicates.
   * Returns \ref MDBX_SUCCESS if the greater pair was returned or
   * \ref MDBX_NOTFOUND otherwise. */
  public static let setUpperBound = MDBXCursorOperations(rawValue: libmdbx.MDBX_SET_UPPERBOUND.rawValue)
}

internal extension MDBXCursorOperations {
  var MDBX_cursor_op: MDBX_cursor_op {
    libmdbx.MDBX_cursor_op(self.rawValue)
  }
}
