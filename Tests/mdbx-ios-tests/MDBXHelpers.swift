//
//  MDBXHelpers.swift
//  mdbx-ios-tests
//
//  Created by Nail Galiaskarov on 5/3/21.
//  Copyright © 2021 MyEtherWallet Inc. All rights reserved.
//

import Foundation
import XCTest
import OSLog

@testable import mdbx_ios

enum Static {
  static let dbName = "pathname_db"
}

func prepareTable(transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase {
  let db = MDBXDatabase()
  try db.open(transaction: transaction, name: "MAINDB", flags: create ? .create : .defaults)
  return db
}

func beginTransaction(transaction: MDBXTransaction, readonly: Bool = false, flags: MDBXTransactionFlags = []) throws {
  if !readonly {
    XCTAssert(!flags.contains(.readOnly))
  }
  
  try transaction.begin(flags: flags)
}

func prepareMultiTable(transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase {
  let db = MDBXDatabase()
  try db.open(transaction: transaction, name: "MULTIDB", flags: create ? [.create, .dupSort] : [.defaults, .dupSort])
  return db
}

func transactionEnd(abort: Bool, transaction: MDBXTransaction) throws {
  if abort {
    try transaction.abort()
  } else {
    try transaction.commit()
  }
}

func prepareCursor(transaction: MDBXTransaction, database: MDBXDatabase) throws -> MDBXCursor {
  let cursor = MDBXCursor()
  try cursor.open(transaction: transaction, database: database)
  
  return cursor
}

func dbOpen(environment: MDBXEnvironment) {
  let logger = OSLog(subsystem: "mdbx-ios.test.helpers", category: #function)
  do {
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(Static.dbName).path
    os_log("=============", log: logger, type: .info)
    os_log("DB PATH: %@", log: logger, type: .info, path)
    os_log("=============", log: logger, type: .info)
    try environment.open(path: path, flags: .envDefaults, mode: .iOSPermission)
  } catch {
    XCTFail(error.localizedDescription)
  }
}

func dbDelete() {
  let path = FileManager.default.temporaryDirectory.appendingPathComponent(Static.dbName).path
  try? FileManager.default.removeItem(atPath: path)
}

func dbPrepare() -> MDBXEnvironment? {
  let environment = MDBXEnvironment()
  do {
    try environment.create()
    var ctx = Data.some
    try environment.unsafeSetContext(&ctx)
    try environment.setMaxReader(42)
    try environment.setMaxDatabases(42)
    
    let geometry = MDBXGeometry(sizeLower: -1,
                                sizeNow: 1024 * 10,
                                sizeUpper: 1024 * 1024 * 50,
                                growthStep: 1024,
                                shrinkThreshold: -1,
                                pageSize: -1)
    try environment.setHandleSlowReaders { (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
      
      //     debugPrint(env ?? "")
      //     debugPrint(txn ?? "")
      //     debugPrint(pid)
      //     debugPrint(tid ?? "")
      //     debugPrint(laggard)
      //     debugPrint(gap)
      //     debugPrint(space)
      //     debugPrint(retry)
      //
      //     rc = mdbx_env_set_hsr(env, testcase::hsr_callback);
      //     if (unlikely(rc != MDBX_SUCCESS))
      //       failure_perror("mdbx_env_set_hsr()", rc);
      //
      //     rc = mdbx_env_set_geometry(
      //         env, config.params.size_lower, config.params.size_now,
      //         config.params.size_upper, config.params.growth_step,
      //         config.params.shrink_threshold, config.params.pagesize);
      //     if (unlikely(rc != MDBX_SUCCESS))
      //       failure_perror("mdbx_env_set_mapsize()", rc);
      //
      //     log_trace("<< db_prepare");s
      return -1
    }
    try environment.setGeometry(geometry)
  } catch {
    XCTFail(error.localizedDescription)
  }

  return environment
}

func drop(transaction: MDBXTransaction, database: MDBXDatabase, delete: Bool) throws {
  try transaction.drop(database: database, delete: delete)
}
