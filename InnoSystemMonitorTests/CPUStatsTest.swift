//
//  CPUStatsTest.swift
//  InnoSystemMonitorTests
//
//  Created by Matvey Plevako on 15.02.2021.
//

import XCTest
@testable import InnoSystemMonitor



class CPUStatsTest: XCTestCase {
    var classInstance: CPUStats!

    override func setUpWithError() throws {
        classInstance = CPUStats()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFormatingWithoutSpaces() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testString = "435  19.9 WindowServer"
        let proc = classInstance.parseProcessLine(testString)
        XCTAssert(proc.0 == "WindowServer", "invalid name")
        XCTAssert(proc.1 == 435, "invalid pid")
        XCTAssert(proc.2 == 19.9, "invalid proc usage")
    }
    
    func testFormatingWithSpaces() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testString = "80700   1.2 Safari Helper (Renderer)"
        let proc = classInstance.parseProcessLine(testString)
        XCTAssert(proc.0 == "Safari Helper (Renderer)", "invalid name")
        XCTAssert(proc.1 == 80700, "invalid pid")
        XCTAssert(proc.2 == 1.2, "invalid proc usage")
    }

    func testPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            let _ = classInstance.read(callback: { _ in
            })
        }
    }

}
