//
//  RAMStatsTest.swift
//  InnoSystemMonitorTests
//
//  Created by Matvey Plevako on 16.02.2021.
//

import XCTest
@testable import InnoSystemMonitor

class RAMStatsTest: XCTestCase {
    var classInstance: RAMStats!

    override func setUpWithError() throws {
        classInstance = RAMStats()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFormatingWithoutSpaces() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testString = "80745  lldb-rpc-server  736M"
        let proc = classInstance.parseProcessLine(testString)
        XCTAssert(proc.0 == "lldb-rpc-server", "invalid name")
        XCTAssert(proc.1 == 80745, "invalid pid")
        XCTAssert(proc.2 == 736.0, "invalid proc usage")
    }

    func testPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            let _ = classInstance.read(callback: { _ in
            })
        }
    }

}
