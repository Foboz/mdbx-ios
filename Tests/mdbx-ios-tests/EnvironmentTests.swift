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
      try env.open(path: "test.mdbx2", flags: .envDefaults, mode: .iOSPermission)
      let tx = MDBXTransaction(env)
      
      var context: Any = "testContexthsdbfjsd bfgjhsdbfgjhdbfgjhb sdgjhbds jghbd fgjhdbgj "
//      try tx.begin(flags: .readOnly, context: &context)
      try tx.begin(flags: .readOnly)
      try tx.unsafeSetContext(&context)
      context = "trololo?"
      let test: Any? = tx.unsafeGetContext()
      debugPrint(test)
      try tx.unsafeResetContext()
      let test2: Any? = tx.unsafeGetContext()
      debugPrint(test2)
      
      try tx.break()
      try tx.break()
      
      XCTAssertTrue(true)
    } catch {
      debugPrint(error)
      XCTFail(error.localizedDescription)
    }
  }
}
