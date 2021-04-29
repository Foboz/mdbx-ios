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
  
  func testTransactionId() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      XCTAssert(transaction.id == 0) // inactive
      try beginTransaction(transaction: transaction)
      XCTAssert(transaction.id > 0) // active
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionFlags() {
    do {
      dbOpen()
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction, readonly: true, flags: [.readOnly])
      XCTAssertTrue(transaction.flags.contains(.readOnly))
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionIsDirty() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var data = Data.some
      var key = Data.some

      try writeData(key: key, value: data, commit: false)
      var result = try _transaction!.isDirty(data: &key)

      try _transaction!.commit()
      try beginTransaction(transaction: _transaction!)
      result = try _transaction!.isDirty(data: &key)
      XCTAssertTrue(result)
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
  
  func testDBIsequence() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var value = try _transaction!.dbiSequence(database: _table!, increment: 1)
      XCTAssert(value == 0)
      
      try writeData(key: Data.some, value: Data.some)
      value = try _transaction!.dbiSequence(database: _table!, increment: 1)
      XCTAssert(value == 1)
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
  
  func testReadEqualOrGreaterValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var key = Data.any
      let value = try _transaction!.getValueEqualOrGreater(for: &key, database: _table!)
      XCTAssert(value == Data.some)
      XCTAssert(key == Data.some)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadNotExistingEqualOrGreaterValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key = Data.any
      let _ = try _transaction!.getValueEqualOrGreater(for: &key, database: _table!)
      XCTFail("should fail with not found error")
    } catch MDBXError.notFound {
      XCTAssert(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadNonExistingKey() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var some = Data.some
      _ = try _transaction!.getValue(
        for: &some,
        database: _table!
      )
      XCTFail("should throw an error")
    } catch MDBXError.notFound {
      XCTAssertTrue(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testInvalidInsert() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      try _transaction!.break()
      try writeData(key: Data.some, value: Data.some)
      XCTFail("should fail")
    } catch MDBXError.badTransaction {
      XCTAssertTrue(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testInsertForReadonly() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      try _transaction!.break()
      try _transaction!.abort()
      
      _transaction = prepareTransaction()
      try beginTransaction(transaction: _transaction!, readonly: true, flags: [.readOnly])
            
      try writeData(key: Data.some, value: Data.some)
    } catch MDBXError.EACCESS {
      XCTAssert(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  
  func testTransactionRenew() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      try _transaction!.break()
      try _transaction!.abort()
      
      let readTransaction = prepareTransaction()
      try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])
      var key = Data.some
      _ = try readTransaction.getValue(for: &key, database: _table!)
      try readTransaction.reset()
      
      do {
        _ = try readTransaction.getValue(for: &key, database: _table!)
      } catch MDBXError.badTransaction {
        XCTAssertTrue(true)
      } catch {
        XCTFail(error.localizedDescription)
      }
      try readTransaction.renew()
      _ = try readTransaction.getValue(for: &key, database: _table!)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionAbortBeforeCommit() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      try writeData(key: Data.some, value: Data.some, commit: true)
      try writeData(key: Data.any, value: Data.any, commit: false)

      try _transaction!.abort()
      
      let readTransaction = prepareTransaction()
      try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])

      var key = Data.any
      let _ = try readTransaction.getValue(for: &key, database: _table!)
      XCTFail("should fail with notfound")
    } catch MDBXError.notFound {
      XCTAssertTrue(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionAbortBeforeFirstCommit() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      try _transaction!.abort()
      
      let readTransaction = prepareTransaction()
      try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])

      var key = Data.any
      let _ = try readTransaction.getValue(for: &key, database: _table!)
      XCTFail("should fail with notfound")
    } catch MDBXError.badDatabase {
      XCTAssertTrue(true)
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

  func testReadNotExistValueEx() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key = Data.some
      var valuesCount = 0
      let _ = try _transaction!.getValueEx(for: &key, database: _table!, valuesCount: &valuesCount)
      XCTFail("should throw error")
    } catch MDBXError.notFound {
      XCTAssertTrue(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testCompareEqualKeys() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key1 = Data.some
      var key2 = Data.some

      let result = _transaction!.compare(a: &key1, b: &key2, database: _table!)
      XCTAssert(result == 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCompareNotEqualKeys() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var key1 = Data.some
      var key2 = Data.any
            
      let result = _transaction!.compare(a: &key1, b: &key2, database: _table!)
      XCTAssert(result > 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCompareNotEqualValues() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()

      var value1 = Data.someInt
      var value2 = Data.veryLargeInt
      
      let result = _transaction!.databaseCompare(a: &value1, b: &value2, database: _table!)
      XCTAssert(result < 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCompareEqualValues() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()

      var value1 = Data.someInt
      var value2 = Data.someInt
      
      let result = _transaction!.databaseCompare(a: &value1, b: &value2, database: _table!)
      XCTAssert(result == 0)
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
  
  func testReplaceNonExisingKey() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      var some = Data.some
      var any = Data.any

      let oldData = try _transaction!.replace(
        new: &some,
        forKey: &any,
        database: _table!,
        flags: [.upsert]
      )
      let value = try _transaction!.getValue(
        for: &any,
        database: _table!
      )
      XCTAssert(oldData == Data())
      XCTAssert(value == Data.some)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReplaceForReadonly() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable_WriteSomeData()
      try _transaction!.break()
      try _transaction!.abort()
      
      _transaction = prepareTransaction()
      try beginTransaction(transaction: _transaction!, readonly: true, flags: [.readOnly])
      
      var some = Data.some
      var any = Data.any
      
      let _ = try _transaction!.replace(
        new: &any,
        forKey: &some,
        database: _table!,
        flags: [.upsert]
      )
    } catch MDBXError.EACCESS {
      XCTAssert(true)
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
  
  func testRemoveNonExistingValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      var some = Data.some
      try _transaction!.delete(key: &some, database: _table!)
    } catch MDBXError.notFound {
      XCTAssert(true)
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
  
  func testTableClearError() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      try _transaction!.break()
      try _transaction!.abort()
      
      let readTransaction = prepareTransaction()
      try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])
      
      try readTransaction.drop(database: _table!, delete: false)
    } catch MDBXError.EACCESS {
      XCTAssert(true)
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
  
  func testCommitExError() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      let value = Data.some
      let key = Data.some
      
      try writeData(key: key, value: value, commit: false)
      try _transaction!.abort()
      let _ = try _transaction!.commitEx()
      XCTFail("should throw error")
    } catch MDBXError.badTransaction {
      XCTAssert(true)
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
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable(supportDuplicates: true)
      
      var value = Data.some
      var key = Data.some
      
      var anyValue = Data.any
      var anyKey = Data.any
      
      try _cursor!.put(value: &value, key: &key, flags: [.upsert])
      try _cursor!.put(value: &anyValue, key: &key, flags: [.upsert])
      
      var valuesCount = 0
      let _ = try _transaction?.getValueEx(for: &key, database: _table!, valuesCount: &valuesCount)
      XCTAssert(valuesCount == 2)
      XCTAssert(try _cursor!.count() == 2)

      try _cursor!.put(value: &anyValue, key: &anyKey, flags: [.upsert])
      
      let data = try _cursor!.getValue(key: &anyKey, operation: [.first, .setKey])
      XCTAssert(anyKey == Data.any)
      XCTAssert(data == anyValue)
      
      var emptyKey = Data()
      let firstData = try _cursor!.getValue(key: &emptyKey, operation: [.first, .setLowerBound])
      XCTAssertTrue(try _cursor!.onFirst())
      XCTAssertFalse(try _cursor!.onLast())
      XCTAssertTrue(emptyKey == Data.any)
      XCTAssertTrue(firstData == anyValue)

      let data1 = try _cursor!.getValue(key: &emptyKey, operation: [.next])
      XCTAssertTrue(emptyKey == Data.some)
      XCTAssertTrue(data1 == anyValue)
      
      let prev = try _cursor!.getValue(key: &emptyKey, operation: [.prev])
      XCTAssertTrue(emptyKey == Data.any)
      XCTAssertTrue(prev == anyValue)

      let next = try _cursor!.getValue(key: &emptyKey, operation: [.next])
      XCTAssertTrue(emptyKey == Data.some)
      XCTAssertTrue(next == anyValue)

      let data2 = try _cursor!.getValue(key: &emptyKey, operation: [.next])
      XCTAssertTrue(emptyKey == Data.some)
      XCTAssertTrue(data2 == value)
      XCTAssertTrue(try _cursor!.onLast())
      XCTAssertFalse(try _cursor!.onFirst())

      do {
        _ = try _cursor!.getValue(key: &key, operation: [.next])
        XCTFail("should throw not found error")
      } catch MDBXError.notFound {
        XCTAssert(true)
      } catch {
        throw error
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorPutHandleError() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable(supportDuplicates: true)
      
      var value = Data.some
      var key = Data.some
      
      var anyValue = Data.any      
      try _cursor!.put(value: &value, key: &key, flags: [.noOverWrite])
      try _cursor!.put(value: &anyValue, key: &key, flags: [.noOverWrite])
    } catch MDBXError.keyExist {
      XCTAssertTrue(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorCountError() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor()
      _ = try _cursor!.count()
      XCTFail("cursor should fail")
    } catch MDBXError.EINVAL {
      XCTAssert(true)
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
  
  func testCursorDeleteNonExistingValue() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      try _cursor!.delete(flags: [.upsert])
    } catch MDBXError.ENODATA {
      XCTAssert(true)
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
  
  func prepareMultiTable(transaction: MDBXTransaction, create: Bool) throws -> MDBXDatabase {
    let db = MDBXDatabase()
    try db.open(transaction: transaction, name: "MULTIDB", flags: create ? [.create, .dupSort] : [.defaults, .dupSort])
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
  
  func dbOpen_PrepareTransaction_MultiTable_Cursor() throws {
    dbOpen_PrepareTransaction()
    
    try beginTransaction(transaction: _transaction!)
    _table = try prepareMultiTable(transaction: _transaction!, create: true)
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
  
  func dbOpen_PrepareTransaction_Table_Cursor_ClearTable(supportDuplicates: Bool = false) throws {
    if supportDuplicates {
      try dbOpen_PrepareTransaction_MultiTable_Cursor()
    } else {
      try dbOpen_PrepareTransaction_Table_Cursor()
    }
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


//bool testcase_try::run() {
//  db_open();
//  assert(!txn_guard);
//
//  MDBX_txn *txn = nullptr;
//  MDBX_txn *txn2 = nullptr;
//  int rc = mdbx_txn_begin(db_guard.get(), nullptr, MDBX_TXN_READWRITE, &txn);
//  if (unlikely(rc != MDBX_SUCCESS))
//    failure_perror("mdbx_txn_begin(MDBX_TXN_TRY)", rc);
//  else {
//    rc = mdbx_txn_begin(db_guard.get(), nullptr, MDBX_TXN_TRY, &txn2);
//    if (unlikely(rc != MDBX_BUSY))
//      failure_perror("mdbx_txn_begin(MDBX_TXN_TRY)", rc);
//  }
//
//  txn_guard.reset(txn);
//  return true;
//}
