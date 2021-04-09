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
    env.create()
    XCTAssertTrue(true)
  }
}
