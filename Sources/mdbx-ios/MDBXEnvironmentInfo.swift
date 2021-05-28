//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 4/21/21.
//

import Foundation

/** \brief Information about the environment
 * \ingroup c_statinfo
 * \see mdbx_env_info_ex() */

public struct MDBXEnvironmentInfo {
  public struct GeoMeta {
    let lower: UInt64 /**< Lower limit for datafile size */
    let upper: UInt64 /**< Upper limit for datafile size */
    let current: UInt64 /**< Current datafile size */
    let shrink: UInt64 /**< Shrink threshold for datafile */
    let grow: UInt64 /**< Growth step for datafile */
  }
  
  public struct Meta {
    let x: UInt64
    let y: UInt64
  }
  
  public struct BootMeta {
    let current: Meta
    let meta0: Meta
    let meta1: Meta
    let meta2: Meta
  }
  
  public let geo: GeoMeta
  
  //   As such it can be used to identify the local machine's current boot. MDBX
  //   uses such when open the database to determine whether rollback required to
  //   the last steady sync point or not. I.e. if current bootid is differ from the
  //   value within a database then the system was rebooted and all changes since
  //   last steady sync must be reverted for data integrity. Zeros mean that no
  //   relevant information is available from the system. */
  public let bootId: BootMeta
  
  public let mapSize: UInt64 /**< Size of the data memory map */
  public let lastPageNumber: UInt64 /**< Number of the last used page */
  public let recentTxnId: UInt64 /**< ID of the last committed transaction */
  public let latterReaderTxnId: UInt64 /**< ID of the last reader transaction */
  public let selfLatterReaderTxnId: UInt64 /**< ID of the last reader transaction of caller process */
  public let meta0_txnId, meta0_sign: UInt64
  public let meta1_txnId, meta1_sign: UInt64
  public let meta2_txnId, meta2_sign: UInt64
  
  public let maxReaders: UInt32 /**< Total reader slots in the environment */
  public let numReaders: UInt32 /**< Max reader slots used in the environment */
  public let databasePageSize: UInt32 /**< Database pagesize */
  public let systemPageSize: UInt32 /**< System pagesize */
  
  /** Bytes not explicitly synchronized to disk */
  public let unsyncVolume: UInt64
  /** Current auto-sync threshold, see \ref mdbx_env_set_syncbytes(). */
  public let autosyncThreshold: UInt64
  /** Time since the last steady sync in 1/65536 of second */
  public let timeSinceLastSync: UInt32
  /** Current auto-sync period in 1/65536 of second,
  //   * see \ref mdbx_env_set_syncperiod(). */
  public let autoSyncPeriod: UInt32
  //  /** Time since the last readers check in 1/65536 of second,
  //   * see \ref mdbx_reader_check(). */
  public let timeSinceLastReadersCheck: UInt32
  //  /** Current environment mode.
  //   * The same as \ref mdbx_env_get_flags() returns. */
  public let mode: UInt32
}
