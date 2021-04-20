//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 4/19/21.
//

import XCTest
@testable import mdbx_ios

final class MDBXTests: XCTestCase {
  
  private var _environment: MDBXEnvironment?
  
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
    self._environment = nil
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
                                  sizeNow: 1024 * 1024 * 256,
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
  
  func dbOpen() {
    let envFlags: MDBXEnvironmentFlags = [.noSubDir, .writeMap, .safeNoSync, .noMemoryInit, .coalesce, .lifoReclaim, .accede]
    do {
      let path = FileManager.default.temporaryDirectory.appendingPathComponent("pathname_db").path
      try _environment?.open(path: path, flags: envFlags, mode: MDBXEnvironmentMode(rawValue: 0640))
      addTeardownBlock {
        try? FileManager.default.removeItem(atPath: path)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func dbClose() {
    self._environment?.close()
  }
  
  func testDBOpen() {
    dbOpen()
    addTeardownBlock {
      self.dbClose()
    }
  }
  
  func beginTransaction(readonly: Bool, flags: MDBXTransactionFlags) {
    XCTAssert(!flags.contains(.readOnly))
  }
  
//    void testcase::txn_begin(bool readonly, MDBX_txn_flags_t flags) {
//      assert((flags & MDBX_TXN_RDONLY) == 0);
//      log_trace(">> txn_begin(%s, 0x%04X)", readonly ? "read-only" : "read-write",
//                flags);
//      assert(!txn_guard);
//
//      MDBX_txn *txn = nullptr;
//      int rc = mdbx_txn_begin(db_guard.get(), nullptr,
//                              readonly ? flags | MDBX_TXN_RDONLY : flags, &txn);
//      if (unlikely(rc != MDBX_SUCCESS))
//        failure_perror("mdbx_txn_begin()", rc);
//      txn_guard.reset(txn);
//      need_speculum_assign = config.params.speculum && !readonly;
//
//      log_trace("<< txn_begin(%s, 0x%04X)", readonly ? "read-only" : "read-write",
//                flags);
//    }

}
