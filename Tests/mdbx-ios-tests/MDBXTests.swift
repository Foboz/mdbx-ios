//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/19/21.
//

import XCTest
@testable import mdbx_ios

private enum Cursors: Int {
  case lowerbound
  case prev
  case prev_prev
  case next
  case next_next
}

final class MDBXTests: XCTestCase {
  
  private var _environment: MDBXEnvironment?
  
  private var _transaction: MDBXTransaction?
  private var _table: MDBXDatabase?
  private var _cursor: MDBXCursor?
  
  override func setUp() {
    super.setUp()
    self._environment = dbPrepare()
    
    guard self._environment != nil else {
      XCTFail("Can't prepare DB")
      return
    }
  }
  
  override func tearDown() {
    super.tearDown()
    try? _transaction?.abort()
    _cursor?.close()
    _cursor = nil
    _transaction = nil
    _table?.close()
    _table = nil
    _environment?.close()
    _environment = nil
  }
  
  func dbPrepare() -> MDBXEnvironment? {
    let environment = MDBXEnvironment()
    do {
      try environment.create()
      var mutSelf = self
      try environment.unsafeSetContext(&mutSelf)
      try environment.setMaxReader(42)
      try environment.setMaxDatabases(42)
      
      let geometry = MDBXGeometry(sizeLower: -1,
                                  sizeNow: 1024 * 32,
                                  sizeUpper: -1,
                                  growthStep: -1,
                                  shrinkThreshold: -1,
                                  pageSize: -1)
      try environment.setHandleSlowReaders { (env, txn, pid, tid, laggard, gap, space, retry) -> Int32 in
        debugPrint(env ?? "")
        debugPrint(txn ?? "")
        debugPrint(pid)
        debugPrint(tid ?? "")
        debugPrint(laggard)
        debugPrint(gap)
        debugPrint(space)
        debugPrint(retry)
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
    
  func testDBOpen() {
    dbOpen()
    addTeardownBlock {
      self.dbClose()
    }
  }
    
  func testBeginTransaction() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testBreakableCommit() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      try transaction.commit()
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorOpen() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      let database = try prepareTable(transaction: transaction, create: true)
      let cursor = try prepareCursor(transaction: transaction, database: database)
      
      addTeardownBlock {
        cursor.close()
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorClose() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      let database = try prepareTable(transaction: transaction, create: true)
      let cursor = try prepareCursor(transaction: transaction, database: database)
      
      cursor.close()
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testInsert() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      try _transaction!.drop(database: _table!, delete: false)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var some = Data.some
      let value = try _transaction!.getValue(
        for: &some,
        database: _table!
      )
      XCTAssert(value == Data.some)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadValueEx() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var key = Data.some
      var valuesCount = 0
      let value = try _transaction!.getValueEx(for: &key, database: _table!, valuesCount: &valuesCount)
      XCTAssert(valuesCount == 1)
      XCTAssert(value == Data.some)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCompareEqualValues() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key1 = Data.some
      var key2 = Data.some
      let value = Data.some
      
      try writeData(key: key1, value: value)
      try writeData(key: key2, value: value)
      
      let result = _transaction!.compare(a: &key1, b: &key2, database: _table!)
      XCTAssert(result == 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCompareNotEqualValues() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key1 = Data.some
      var key2 = Data.some
      let value1 = Data.someInt
      let value2 = Data.veryLargeInt
      
      try writeData(key: key1, value: value1)
      try writeData(key: key2, value: value2)
      
      let result = _transaction!.compare(a: &key1, b: &key2, database: _table!)
      //XCTAssert(result < 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReplaceValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var some = Data.some
      var any = Data.any

      let oldData = try _transaction!.replace(
        new: &any,
        forKey: &some,
        database: _table!,
        flags: [.upsert]
      )

      let value = try _transaction!.getValue(
        for: &some,
        database: _table!
      )
      XCTAssert(oldData == Data.some)
      XCTAssert(value == Data.any)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testRemoveValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var some = Data.some
      let value = try _transaction!.getValue(
        for: &some,
        database: _table!
      )
      XCTAssertNotNil(value)

      try _transaction!.delete(key: &some, database: _table!)
      do {
        _ = try _transaction!.getValue(
          for: &some,
          database: _table!
        )
        XCTFail("getValue should throw not found")
      } catch MDBXError.notFound {
        XCTAssert(true)
      } catch {
        throw(error)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTableClear() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var value = Data.some
      var key = Data.some
      
      try writeData(key: key, value: value)
      try _transaction!.drop(database: _table!, delete: false)
      
      do {
        _ = try _transaction!.getValue(
          for: &key,
          database: _table!
        )
        XCTFail("getValue should throw not found")
      } catch MDBXError.notFound {
        XCTAssertTrue(true)
      } catch {
        throw(error)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCommitEx() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      let value = Data.some
      let key = Data.some
      
      try writeData(key: key, value: value, commit: false)
      let latency = try _transaction!.commitEx()
      XCTAssert(latency.write < 10)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorPut() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      
      var value = Data.some
      var key = Data.some
      try _cursor!.put(value: &value, key: &key, flags: [.upsert])
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorRead() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      
      var value = Data.some
      var key = Data.some
      try _cursor!.put(value: &value, key: &key, flags: [.upsert])
      
      let data = try _cursor!.getValue(key: &key, operation: [.first])
      XCTAssert(data == value)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorDelete() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      
      var value = Data.some
      var key = Data.some
      try _cursor!.put(value: &value, key: &key, flags: [.upsert])
      
      try _cursor!.delete(flags: [.upsert])
      do {
        let _ = try _cursor!.getValue(key: &key, operation: [.first])
        XCTFail("should fail with not found error")
      } catch MDBXError.notFound {
        XCTAssert(true)
      } catch {
        XCTFail(error.localizedDescription)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}

extension MDBXTests {
  func dbOpen() {
    do {
      let path = FileManager.default.temporaryDirectory.appendingPathComponent("pathname_db").path
      debugPrint("================")
      debugPrint("DB PATH: \(path)")
      debugPrint("================")
      try _environment?.open(path: path, flags: .envDefaults, mode: .iOSPermission)
      addTeardownBlock {
        try? FileManager.default.removeItem(atPath: path)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func prepareTransaction() -> MDBXTransaction {
    XCTAssertNotNil(_environment)
    
    return MDBXTransaction(_environment!)
  }
  
  func prepareTable(transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase {
    let db = MDBXDatabase()
    try db.open(transaction: transaction, name: "MAINDB", flags: create ? .create : .defaults)
    return db
  }
  
  func prepareCursor(transaction: MDBXTransaction, database: MDBXDatabase) throws -> MDBXCursor {
    let cursor = MDBXCursor()
    try cursor.open(transaction: transaction, database: database)
    
    return cursor
  }
  
  func beginTransaction(transaction: MDBXTransaction, readonly: Bool = false, flags: MDBXTransactionFlags = []) throws {
    if !readonly {
      XCTAssert(!flags.contains(.readOnly))
    }
    
    try transaction.begin(flags: flags)
  }
    
  func dbClose() {
    self._environment?.close()
  }
  
  func drop(transaction: MDBXTransaction, database: MDBXDatabase, delete: Bool) throws {
    try transaction.drop(database: database, delete: delete)
  }
  
  func dbOpen_PrepareTransaction() {
    dbOpen()
    _transaction = prepareTransaction()
  }
  
  func dbOpen_PrepareTransaction_Table_Cursor() throws {
    dbOpen_PrepareTransaction()
    
    try beginTransaction(transaction: _transaction!)
    _table = try prepareTable(transaction: _transaction!, create: true)
    _cursor = try prepareCursor(transaction: _transaction!, database: _table!)
  }
  
  func writeData(key: Data, value: Data, commit: Bool = true) throws {
    var key = key
    var value = value
    try _transaction!.put(
      value: &value,
      forKey: &key,
      database: _table!,
      flags: [.upsert]
    )

    if commit {
      try _transaction!.commit()
      try beginTransaction(transaction: _transaction!)
    }
  }
  
  func dbOpen_PrepareTransaction_Table_Cursor_ClearTable() throws {
    try dbOpen_PrepareTransaction_Table_Cursor()
    try _transaction!.drop(database: _table!, delete: false)
  }
  
  func dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData() throws {
    try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
    try writeData(key: Data.some, value: Data.some)
  }
  
  func dbOpen_PrepareTransaction_Table_Cursor_CloseCursor() throws {
    try dbOpen_PrepareTransaction_Table_Cursor()
    _cursor!.close()
  }
  
  func transactionEnd(abort: Bool, transaction: MDBXTransaction) throws {
    if abort {
      try transaction.abort()
    } else {
      try transaction.commit()
    }
  }
}
