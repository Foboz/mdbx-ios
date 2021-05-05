//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/3/21.
//

import Foundation
import XCTest

@testable import mdbx_ios

//
// measure открыть весь стек в кейсе и прогнать записи транзакций
// geometry size, поиграться с настройками чтобы бд была self-resizable
// несколько потоков. тесты на чтение и запись
//

final class OtherTests: XCTestCase {
  let semaphore = DispatchSemaphore(value: 1)

  override func tearDown() {
    super.tearDown()

    dbDelete()
  }
  
  func testWriteMeasure() {
    measure {
      do {
        _ = try writeSome()
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
  }
  
  func testReadMeasure() {
    let (txn, db, env) = try! writeSome()
        
    let readTransaction = MDBXTransaction(env)
    try! beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])
    measure {
      var key = Data.some
      
      do {
        let value = try readTransaction.getValue(for: &key, database: db)
        XCTAssert(value == Data.some)
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
  }
  
  func testWriteAsyncRead() {
    let expectation = XCTestExpectation(description: "Read values in background thread")

    let (txn, db, env) = try! writeSome()
    DispatchQueue.global().async {
      let readTransaction = MDBXTransaction(env)
      try! beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])
      var key = Data.some

      do {
        let value = try readTransaction.getValue(for: &key, database: db)
        XCTAssert(value == Data.some)
        expectation.fulfill()
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
  func testAsyncReadWrite() {
    dbDelete()

    let numberOfCommits = 200000

    let env = dbPrepare()!
    dbOpen(environment: env)
    var db: MDBXDatabase?
    var cursor: MDBXCursor?

    let expectation = XCTestExpectation(description: "Read/write some in background thread")
    
    let keyGenerator = Generator<Int>(value: -100)
    let valueGenerator = Generator<Int>(value: 212)

    let write = DispatchQueue(label: "writeQueue")
    var writeChecksum = 0
    
    write.async {
      Thread.sleep(forTimeInterval: 0.01)
      var numberOfOps = 0
      let transaction = MDBXTransaction(env)
      do {
        try beginTransaction(transaction: transaction)
      } catch {
        XCTFail(error.localizedDescription)
        abort()
      }

      while numberOfOps < numberOfCommits {
        do {
          if db == nil {
            db = try prepareTable(transaction: transaction, create: true)
          }
                    
          var dataInt = valueGenerator.value
          var keyInt = keyGenerator.value
          
          var data = Int.asData(value: &dataInt)
          var key = Int.asData(value: &keyInt)
          
          try transaction.put(value: &data, forKey: &key, database: db!, flags: [.upsert])
          
          if numberOfOps % 42 == 0 {
            try transaction.commit()
            try beginTransaction(transaction: transaction)
          }
          
          _ = keyGenerator.decrement()
          _ = valueGenerator.increment()
          
          writeChecksum = writeChecksum ^ keyInt ^ dataInt ^ numberOfOps
          numberOfOps += 1
        } catch {
          XCTFail(error.localizedDescription)
          break
        }
      }
      
      do {
        try transaction.commit()
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
    
    let read = DispatchQueue(label: "readQueue")
    var readChecksum = 0
        
    read.async {
      var attempts = 0
      while attempts < 1000 {
        Thread.sleep(forTimeInterval: 0.2)

        guard let db = db else {
          continue
        }
        
        let readTransaction = MDBXTransaction(env)
        do {
          let date = Date()
          try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])

          if cursor == nil {
            cursor = try prepareCursor(transaction: readTransaction, database: db)
          } else {
            try cursor!.renew(transaction: readTransaction)
          }
          
          var key = Data()
          var readCount = 0
          let value = try cursor!.getValue(key: &key, operation: [.first, .setLowerBound])
          readChecksum = key.toInt() ^ value.toInt() ^ readCount

          var end = false
          while end == false {
            readCount += 1
            
            do {
              let value = try cursor!.getValue(key: &key, operation: [.next])
              readChecksum = readChecksum ^ key.toInt() ^ value.toInt() ^ readCount
            } catch {
              end = true
            }
          }
          if readChecksum == writeChecksum && readCount == numberOfCommits {
            debugPrint("=============")
            debugPrint("testAsyncReadWrite 187: successful read on \(attempts) attempt. Total time: \(abs(date.timeIntervalSinceNow)) secs")
            debugPrint("=============")
            expectation.fulfill()
            break
          } else {
            attempts += 1
          }
        } catch {
          debugPrint(error.localizedDescription)
          attempts += 1
        }
        try? readTransaction.break()
        try? readTransaction.abort()
      }
    }
    
    wait(for: [expectation], timeout: 10)
    env.close()
  }
  
  private func writeSome() throws -> (txn: MDBXTransaction, db: MDBXDatabase, env: MDBXEnvironment) {
    let env = dbPrepare()!
    dbOpen(environment: env)
          
    let transaction = MDBXTransaction(env)
    try beginTransaction(transaction: transaction)
    
    let database = try prepareTable(transaction: transaction, create: true)

    var data = Data.some
    var key = Data.some
    
    try transaction.put(value: &data, forKey: &key, database: database, flags: [.upsert])
    try transaction.commit()

    return (txn: transaction, db: database, env: env)
  }
}
