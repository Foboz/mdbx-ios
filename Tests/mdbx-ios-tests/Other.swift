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
    let env = dbPrepare()!
    dbOpen(environment: env)
    var db: MDBXDatabase?

    let expectation = XCTestExpectation(description: "Read/write some in background thread")
    

    let write = DispatchQueue(label: "writeQueue")
    write.async {
      Thread.sleep(forTimeInterval: 0.2)
      do {
        let transaction = MDBXTransaction(env)
        try beginTransaction(transaction: transaction)
        
        db = try prepareTable(transaction: transaction, create: true)

        var data = Data.some
        var key = Data.some
        
        try transaction.put(value: &data, forKey: &key, database: db!, flags: [.upsert])
        try transaction.commit()

        Thread.sleep(forTimeInterval: 0.2)
        
        var anyData = Data.any
        var anyKey = Data.any
        try beginTransaction(transaction: transaction)
        try transaction.put(value: &anyData, forKey: &anyKey, database: db!, flags: [.upsert])
        try transaction.commit()        
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
    
    let read = DispatchQueue(label: "readQueue")
    read.async {
      let readTransaction = MDBXTransaction(env)
      
      var attempts = 0
      while attempts < 100 {
        guard let db = db else {
          continue
        }
        
        Thread.sleep(forTimeInterval: 0.05)
        do {
          if attempts == 0 {
            try beginTransaction(transaction: readTransaction, readonly: true, flags: [.readOnly])
          } else {
            try readTransaction.renew()
          }

          var key = Data.some
          let some = try readTransaction.getValue(for: &key, database: db)
          XCTAssert(some == Data.some)
          
          var anyKey = Data.any
          let any = try readTransaction.getValue(for: &anyKey, database: db)
          XCTAssert(any == Data.any)

          try? readTransaction.abort()
          expectation.fulfill()
          break
        } catch {
          debugPrint(error.localizedDescription)
          try? readTransaction.reset()
          
          attempts += 1
        }
      }
    }
    
    wait(for: [expectation], timeout: 2)
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
