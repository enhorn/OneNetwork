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
            if message == "GET START [Array<User>]: \(url.absoluteString)" {
                logFetchingExpectation.fulfill()
            } else if message == "GET DONE [Array<User>]: \(url.absoluteString)" {
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
            if message == "GET START [Array<User>]: \(url.absoluteString)" {
                logFetchingExpectation.fulfill()
            } else if message == "GET DONE [Array<User>]: \(url.absoluteString)" {
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

    func testBasicPost() {
        let url = URL(string: "https://reqres.in/api/login")!

        let loginExpectation = expectation(description: "Logged in")
        let logginInExpectation = expectation(description: "Expect to get the fetching message")
        let LoggedInExpectation = expectation(description: "Expect to get the fetched message")

        logger.onInfo = { message in
            if message == "POST START [TokenSuccess]: \(url.absoluteString)" {
                logginInExpectation.fulfill()
            } else if message == "POST DONE [TokenSuccess]: \(url.absoluteString)" {
                LoggedInExpectation.fulfill()
            } else {
                XCTFail("Strange message: \(message)")
            }
        }

        let parameters = ["email": "eve.holt@reqres.in", "password": "lolo"]
        network.post(request: URLRequest(url: url), parameters: parameters, onFetched: { (result: TokenSuccess?) in
            XCTAssertNotNil(result)
            loginExpectation.fulfill()
        }).ifFailed { error in
            print(error)
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation, logginInExpectation, LoggedInExpectation], timeout: 10.0)
    }

}
