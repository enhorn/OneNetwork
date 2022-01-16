//
//  ObservedSubclassedNetworkTests.swift
//  OneNetworkTests
//
//  Created by Robin Enhorn on 2019-10-09.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import XCTest
import Combine
import SwiftUI

class ObservedSubclassedNetworkTests: XCTestCase {

    @ObservedObject var testNetwork: TestNetwork = TestNetwork()
    var cancellable: AnyCancellable?

    override func setUp() {
        testNetwork.users = []
        cancellable = nil
    }

    func testSubclassedAndObservedNetworkSuccess() {
        XCTAssert(testNetwork.users.isEmpty)

        let fetchExpectation = expectation(description: "The fetched users list should be reported.")
        cancellable = testNetwork.objectWillChange.sink {
            fetchExpectation.fulfill()
        }

        testNetwork.fetchUsers()

        waitForExpectations(timeout: 10.0) { error in
            XCTAssertFalse(self.testNetwork.users.isEmpty)
        }
    }

    func testSubclassedAndObservedNetworkFailure() {
        XCTAssert(testNetwork.users.isEmpty)

        cancellable = testNetwork.objectWillChange.sink {
            XCTFail("This should not report an object change")
        }

        let fetchExpectation = expectation(description: "The fetched users list should not be reported.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: fetchExpectation.fulfill)

        testNetwork.fetchUsers(fail: true)
        wait(for: [fetchExpectation], timeout: 10.0)
    }

    func testAsyncUserFetch() {
        Task {
            let users: [User]? = await testNetwork.fetchUsersAsync(fail: false)
            XCTAssertNotNil(users)
            let noUsers: [User]? = await testNetwork.fetchUsersAsync(fail: true)
            XCTAssertNil(noUsers)
        }
    }

}
