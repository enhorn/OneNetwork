//
//  OneCacheTests.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import XCTest
import OneLogger
@testable import OneNetwork

final class OneCacheTests: XCTestCase {

    let cache = OneCache()
    lazy var network = OneNetwork(cache: cache)

    func testCachedData() {
        let request = URLRequest(url: URL(string: "http://nothing.should.ever.be.here.com")!)
        let data = try! JSONEncoder().encode(Cached(title: "Title", value: "Value"))
        let key = OneCacheKey(for: request)

        XCTAssertFalse(cache.hasValue(for: key))
        cache.cacheData(data, for: key)
        XCTAssert(cache.hasValue(for: key))
        XCTAssertNotNil(cache.cache(for: key))


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

        let popped = cache.removeCache(for: key)
        XCTAssertNotNil(popped)
        XCTAssertFalse(cache.hasValue(for: key))
        XCTAssertNil(cache.cache(for: key))
    }

    func testAvoidingCachedData() {
        let request = URLRequest(url: URL(string: "http://nothing.should.ever.be.here.com")!)
        let data = try! JSONEncoder().encode(Cached(title: "Title", value: "Value"))
        let key = OneCacheKey(for: request)

        XCTAssertFalse(cache.hasValue(for: key))
        cache.cacheData(data, for: key)
        XCTAssert(cache.hasValue(for: key))

        let fetchExpectation = expectation(description: "Wait for the cache request to fail.")
        network.get(request: request, useCache: false, onFetched: { (result: Cached?) in
            XCTFail()
            fetchExpectation.fulfill()
        }).ifFailed { _ in
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 10.0)
    }

}

struct Cached: Codable {
    let title: String
    let value: String
}
