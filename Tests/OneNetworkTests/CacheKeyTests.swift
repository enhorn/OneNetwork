//
//  CacheKeyTests.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation
import XCTest
@testable import OneNetwork

final class CacheKeyTests: XCTestCase {

    func testStringRepresentable() {
        let key = OneCacheKey(rawValue: "my key")
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "my key")
    }

    func testURLRequest() {
        let url = URL(string: "http://this.is.a.nice.url.com?query=hello")!
        let request = URLRequest(url: url)
        let key = OneCacheKey(for: request)
        XCTAssertNotNil(key)
        XCTAssertEqual(key.rawValue, "http://this.is.a.nice.url.com?query=hello")
    }

}
