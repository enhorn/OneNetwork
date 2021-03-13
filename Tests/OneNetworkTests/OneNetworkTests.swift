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
        let logHeaders = "{ User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1 }"

        logger.onInfo = { message in
            if message == "GET START [Array<User>]: \(url.absoluteString) \(logHeaders)" {
                logFetchingExpectation.fulfill()
            } else if message == "GET DONE [Array<User>]: \(url.absoluteString) \(logHeaders)" {
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
        let logHeaders = "{ User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1 }"

        logger.onInfo = { message in
            if message == "GET START [Array<User>]: \(url.absoluteString) \(logHeaders)" {
                logFetchingExpectation.fulfill()
            } else if message == "GET DONE [Array<User>]: \(url.absoluteString) \(logHeaders)" {
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
        let loggedInExpectation = expectation(description: "Expect to get the fetched message")
        let logHeaders = "{ Content-Type: application/json; charset=utf-8, User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1 }"

        logger.onInfo = { message in
            if message == "POST START [TokenSuccess]: \(url.absoluteString) \(logHeaders)" {
                logginInExpectation.fulfill()
            } else if message == "POST DONE [TokenSuccess]: \(url.absoluteString) \(logHeaders)" {
                loggedInExpectation.fulfill()
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

        wait(for: [loginExpectation, logginInExpectation, loggedInExpectation], timeout: 10.0)
    }

    func testNullPostWithoutCallback() {
        let url = URL(string: "https://reqres.in/api/login")!

        let logginInExpectation = expectation(description: "Expect to get the fetching message")
        let loggedInExpectation = expectation(description: "Expect to get the fetched message")
        let logHeaders = "{ Content-Type: application/json; charset=utf-8, User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1 }"

        logger.onInfo = { message in
            if message == "POST START [NullResponse]: \(url.absoluteString) \(logHeaders)" {
                logginInExpectation.fulfill()
            } else if message == "POST DONE [NullResponse]: \(url.absoluteString) \(logHeaders)" {
                loggedInExpectation.fulfill()
            } else {
                XCTFail("Strange message: \(message)")
            }
        }

        let parameters: [String: OneNetwork.Parameter] = ["email": .string("eve.holt@reqres.in"), "password": .string("lolo")]
        network.post(request: URLRequest(url: url), parameters: parameters)

        wait(for: [logginInExpectation, loggedInExpectation], timeout: 10.0)
    }

    func testParameterEncoding() {
        let params: [String: OneNetwork.Parameter] = [
            "key1": .string("value1"),
            "key2": .array([
                .string("value2"),
                .bool(true)
            ]),
            "key3": .dictionary([
                "key4": .string("value4"),
                "key5": .array([
                    .number(42),
                    .string("value5")
                ])
            ])
        ]

        let data = try! JSONEncoder().encode(params)

        let facit = "{\"key1\":\"value1\",\"key3\":{\"key4\":\"value4\",\"key5\":[42,\"value5\"]},\"key2\":[\"value2\",true]}"
        XCTAssertEqual(String(data: data, encoding: .utf8)!, facit)
    }

}
