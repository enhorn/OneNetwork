//
//  OneNetworkCacheTests.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import XCTest
@testable import OneNetwork

final class OneNetworkCacheTests: XCTestCase {

    let cache = NSCache<OneNetwork.CacheKey, NSData>()
    lazy var network = OneNetwork(cache: cache)

    func testCachedData() {
        let request = URLRequest(url: URL(string: "http://nothing.should.ever.be.here.com")!)
        let data = try! JSONEncoder().encode(Cached(title: "Title", value: "Value"))

        cache.setObject(data as NSData, forKey: OneNetwork.CacheKey(for: request))

        let fetchExpectation = expectation(description: "Wait for the cached response.")
        network.get(request: request, onFetched: { (result: Cached?) in
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.title, "Title")
            XCTAssertEqual(result?.value, "Value")
            fetchExpectation.fulfill()
        }).ifFailed { error in
            XCTFail()
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 10.0)
    }

}

struct Cached: Codable {
    let title: String
    let value: String
}
