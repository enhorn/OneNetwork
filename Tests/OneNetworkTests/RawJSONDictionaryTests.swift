//
//  RawJSONDictionaryTests.swift
//  
//
//  Created by Robin Enhorn on 2019-10-12.
//

import XCTest
@testable import OneNetwork

final class RawJSONDictionaryTests: XCTestCase {

    let network = OneNetwork()

    func testRawJSONFetch() {
        let data: Data = rawJSON.data(using: .utf8)!
        let json: [NSDictionary] = try! JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
        let fetchExpectation = expectation(description: "Wait for it…")

        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

        network.get(request: URLRequest(url: url), onFetched: { (result: [NSDictionary]?) in
            XCTAssertNotNil(result)
            XCTAssertEqual(result, json)
            fetchExpectation.fulfill()
        }).ifFailed { error in
            fetchExpectation.fulfill()
            print(error)
        }

        waitForExpectations(timeout: 10.0)
    }

}
