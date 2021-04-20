//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/7/21.
//

import XCTest
@testable import mdbx_ios

final class EnvironmentTests: XCTestCase {
  func testSomething() {
    let env = MDBXEnvironment()
    do {
      try env.create()
      try env.open(path: "test.mdbx", flags: .envDefaults, mode: .iOSPermission)
      let tx = MDBXTransaction(env)
      try tx.begin(flags: .readOnly)
      
      var context: Any = "testContexthsdbfjsd bfgjhsdbfgjhdbfgjhb sdgjhbds jghbd fgjhdbgj "
      tx.unsafeSetContext(&context)
      context = "trololo?"
      let test: Any? = tx.unsafeGetContext()
      
      try tx.break()
      try tx.break()
      
      XCTAssertTrue(true)
    } catch {
      debugPrint(error)
      XCTFail(error.localizedDescription)
    }
  }
}
