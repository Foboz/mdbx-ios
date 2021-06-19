//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/19/21.
//

import XCTest
import OSLog
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

    _cursor?.close()
    _cursor = nil
    
    try? _transaction?.break()
    try? _transaction?.abort()
    _transaction = nil
    
    _table?.close()
    _table = nil
    _environment?.close(true)
    _environment = nil
    
    dbDelete()
  }
      
  func testDBOpen() {
    dbOpen(environment: _environment!)
    addTeardownBlock {
      self.dbClose()
    }
  }
  
  func testPath() {
    do {
      dbOpen(environment: _environment!)
      let path = try _environment!.getPath()
      let url = URL(string: path)!
      XCTAssert(url.lastPathComponent == Static.dbName)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
      
  func testBeginTransaction() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      _transaction = transaction
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionId() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      XCTAssert(transaction.id == 0) // inactive
      try beginTransaction(transaction: transaction)
      XCTAssert(transaction.id > 0) // active
      _transaction = transaction
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionFlags() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction, readonly: true, flags: [.readOnly])
      XCTAssertTrue(transaction.flags.contains(.readOnly))
      _transaction = transaction
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testTransactionIsDirty() {
    do {
      try dbOpen_PrepareTransaction_Table_Cursor_ClearTable()
      let data = Data.some
      var key = Data.some

      try writeData(key: key, value: data, commit: false)
      var result = try _transaction!.isDirty(data: &key)

      try _transaction!.commit()
      try beginTransaction(transaction: _transaction!)
      result = try _transaction!.isDirty(data: &key)
      try _transaction!.abort()
      XCTAssertTrue(result)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testBreakableCommit() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      try transaction.commit()
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorOpen() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      let database = try prepareTable(transaction: transaction, create: true)
      let cursor = try prepareCursor(transaction: transaction, database: database)
      _transaction = transaction
      addTeardownBlock {
        cursor.close()
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testCursorClose() {
    do {
      dbOpen(environment: _environment!)
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction)
      let database = try prepareTable(transaction: transaction, create: true)
      let cursor = try prepareCursor(transaction: transaction, database: database)
      
      _transaction = transaction
      _cursor = cursor
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
      
      addTeardownBlock {
        try? readTransaction.abort()
      }
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
      addTeardownBlock {
        try? readTransaction.abort()
      }
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
      addTeardownBlock {
        try? readTransaction.abort()
      }
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

      var value1 = Data.verySmallInt // 0x8000000000000000
      var value2 = Data.veryLargeInt // 0x7fffffffffffffff
      
      // value1 > value2
      let result = _transaction!.databaseCompare(a: &value1, b: &value2, database: _table!)
      XCTAssert(result > 0)
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
      let value = Data.some
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
      addTeardownBlock {
        try? readTransaction.abort()
      }
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
    
  func testTry() {
    do {
      dbOpen(environment: _environment!)
      
      let transaction = prepareTransaction()
      try beginTransaction(transaction: transaction, readonly: false, flags: [.readWrite])
      addTeardownBlock {
        try? transaction.abort()
      }

      let transaction2 = prepareTransaction()
      addTeardownBlock {
        try? transaction2.abort()
      }
      try beginTransaction(transaction: transaction2, readonly: false, flags: [.try])
      XCTFail("should fail with busy")
    } catch MDBXError.busy {
      XCTAssert(true)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  // MARK: Append
  func testNonreverseUniqueAppend() {
    let logger = OSLog(subsystem: "mdbx-ios.test.tests", category: #function)
    do {
      let date = Date()
      try batchWritingAndReading(reverse: false, duplicates: false, maxOps: 500000, logger: logger)
      os_log("=============", log: logger, type: .info)
      os_log("time: %lf", log: logger, type: .info, abs(date.timeIntervalSinceNow))
      os_log("=============", log: logger, type: .info)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReverseUniqueAppend() {
    let logger = OSLog(subsystem: "mdbx-ios.test.tests", category: #function)
    do {
      try batchWritingAndReading(reverse: true, duplicates: false, maxOps: 1_000_000, logger: logger)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testNonreverseNonuniqueAppend() {
    let logger = OSLog(subsystem: "mdbx-ios.test.tests", category: #function)
    do {
      try batchWritingAndReading(reverse: false, duplicates: true, maxOps: 500000, logger: logger)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReverseNonuniqueAppend() {
    let logger = OSLog(subsystem: "mdbx-ios.test.tests", category: #function)
    do {
      try batchWritingAndReading(reverse: true, duplicates: true, maxOps: 500000, logger: logger)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  private func batchWritingAndReading(reverse: Bool, duplicates: Bool, maxOps: Int, batchWrite: Int = 42, logger: OSLog = .default) throws {
    let caption = reverse ? "ahead" : "append"
    os_log("=============", log: logger, type: .info)
    os_log("the %@ scenario selected. Duplicates enabled: %@", log: logger, type: .info, caption, duplicates ? "true" : "false")
    os_log("=============", log: logger, type: .info)
    
    if duplicates {
      try dbOpen_PrepareTransaction_MultiTable_Cursor()
    } else {
      try dbOpen_PrepareTransaction_Table_Cursor()
    }
    
    try _transaction!.drop(database: _table!, delete: false)

    var dbFlags = MDBXDatabaseFlags()
    try databaseFlags(transaction: _transaction!, database: _table!, flags: &dbFlags)
    
    let putFlags = reverse
      ? ((dbFlags.contains(.dupSort)) ? MDBXPutFlags.upsert : MDBXPutFlags.noOverWrite)
      : ((dbFlags.contains(.dupSort)) ? MDBXPutFlags.appendDup : MDBXPutFlags.append)
    
    let keyGenerator = Generator<Int>(value: reverse ? Int.max : 0)
    let valueGenerator = Generator<Int>(value: reverse ? Int.max : 0)
    
    var numberOfOperations = 0
    var insertedCommits = 0
    var insertedChecksum = 0
    
    while numberOfOperations < maxOps {
      let turnKey = dbFlags.contains(.dupSort) == false || Bool.random()
      if turnKey {
        if (reverse ? keyGenerator.decrement() == false : keyGenerator.increment() == false) {
          break
        }
      } else {
        if (reverse ? valueGenerator.decrement() == false : valueGenerator.increment() == false) {
          break
        }
      }
      
      var key = keyGenerator.value
      var data = valueGenerator.value

      var geKey = Int.asData(value: &key)
      var geData = Int.asData(value: &data)
      
      // put values
      
      var expectKeyMismatch = false
      if putFlags.contains(.append) || putFlags.contains(.appendDup) {
        
        do {
          let data = try _transaction!.getValueEqualOrGreater(for: &geKey, database: _table!)
          if data == geData {
            // exact match
            expectKeyMismatch = true
            XCTAssertTrue(numberOfOperations > 0)
          } else {
            switch putFlags {
            case .append:
              expectKeyMismatch = true
            case .appendDup:
              XCTAssert(dbFlags.contains(.dupSort))
              expectKeyMismatch = false
            default:
              break
            }
          }
        } catch MDBXError.notFound {
          expectKeyMismatch = false
        } catch {
          XCTFail("\(error.localizedDescription)")
        }
      }
      
      do {
        try _cursor!.put(value: &geData, key: &geKey, flags: putFlags)
      } catch MDBXError.keyMismatch {
      } catch MDBXError.keyExist {
      } catch {
        XCTFail(error.localizedDescription)
      }

      if (!expectKeyMismatch) {
        insertedChecksum = insertedChecksum ^ geKey.toInt() ^ geData.toInt() ^ insertedCommits
        insertedCommits += 1
      }

      numberOfOperations += 1
      
      if numberOfOperations % batchWrite == 0 {
        do {
          try _transaction!.commit()
          try beginTransaction(transaction: _transaction!)
          try _cursor!.renew(transaction: _transaction!)
        } catch {
          XCTFail(error.localizedDescription)
        }
      }
    }
    
    do {
      try _transaction!.commit()
      try beginTransaction(transaction: _transaction!)
      try _cursor!.renew(transaction: _transaction!)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
    var key = Data()
    
    var readCount = 0
    var readChecksum = 0
    do {
      let value = try _cursor!.getValue(key: &key, operation: reverse ? [.last] : [.first])
      readChecksum = key.toInt() ^ value.toInt() ^ readCount
    } catch {
      XCTFail(error.localizedDescription)
    }
    
    var end = false
    while end == false {
      readCount += 1
      
      do {
        let value = try _cursor!.getValue(key: &key, operation: reverse ? [.prev] : [.next])
        readChecksum = readChecksum ^ key.toInt() ^ value.toInt() ^ readCount
      } catch {
        end = true
      }
    }
    
    XCTAssert(readChecksum == insertedChecksum)
  }
}

extension MDBXTests {
  func prepareTransaction() -> MDBXTransaction {
    XCTAssertNotNil(_environment)
    
    return MDBXTransaction(_environment!)
  }
  
  func dbClose() {
    self._environment?.close()
  }
  
  func dbOpen_PrepareTransaction() {
    dbOpen(environment: _environment!)
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
}
