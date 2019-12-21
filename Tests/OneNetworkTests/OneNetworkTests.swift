//
//  OneNetworkTests.swift
//  OneNetworkTests
//
//  Created by Robin Enhorn on 2019-10-08.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import XCTest
@testable import OneNetwork

final class OneNetworkTests: XCTestCase {

    var logger = TestLogger()
    var network = OneNetwork()

    override func setUp() {
        logger = TestLogger()
        network = OneNetwork(logger: logger)
    }

    func testBasicNetworkSuccess() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

        let fetchExpectation = expectation(description: "Fetching the user list")
        let logFetchingExpectation = expectation(description: "Expect to get the fetching message")
        let logFetchedExpectation = expectation(description: "Expect to get the fetched message")

        logger.onInfo = { message in
            if message == "Fetching [Array<User>]: \(url.absoluteString)" {
                logFetchingExpectation.fulfill()
            } else if message == "Fetched [Array<User>]: \(url.absoluteString)" {
                logFetchedExpectation.fulfill()
            } else {
                XCTFail("Strange message: \(message)")
            }
        }

        network.get(request: URLRequest(url: url), onFetched: { (result: [User]?) in
            XCTAssertNotNil(result)
            XCTAssertFalse(result!.isEmpty)
            fetchExpectation.fulfill()
        }).ifFailed { error in
            print(error)
        }

        wait(for: [fetchExpectation, logFetchingExpectation, logFetchedExpectation], timeout: 10.0)
    }

    func testBasicNetworkFailure() {
        let url = URL(string: "http://some.thing.that.should.not.exist/failing")!
        let fetchExpectation = expectation(description: "This request should not work")
        let logFetchingExpectation = expectation(description: "Expect to get the fetching message")
        let logErrorExpectation = expectation(description: "Expect to get the fetching message")

        logger.onInfo = { message in
            if message == "Fetching [Array<User>]: \(url.absoluteString)" {
                logFetchingExpectation.fulfill()
            } else if message == "Fetched [Array<User>]: \(url.absoluteString)" {
                XCTFail("This should not be called.")
            } else {
                XCTFail("Strange message: \(message)")
            }
        }

        logger.onError = { _ in
            logErrorExpectation.fulfill()
        }

        network.get(request: URLRequest(url: url), onFetched: { (result: [User]?) in
            XCTFail("This should not be called.")
        }).ifFailed { error in
            fetchExpectation.fulfill()
            print(error)
        }

        wait(for: [fetchExpectation, logFetchingExpectation, logErrorExpectation], timeout: 10.0)
    }

}
