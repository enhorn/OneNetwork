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

    let network = OneNetwork()

    func testBasicNetworkSuccess() {
        let query: String = "我的猫喜欢喝牛奶".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let url = URL(string: "https://api.pinyin.pepe.asia/pinyin/\(query)")!
        let fetchExpectation = expectation(description: "Fetching the translation")

        network.get(request: URLRequest(url: url), onFetched: { (result: TestAPIAnser?) in
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.text, "wǒ de māo xǐhuan hē niúnǎi")
            fetchExpectation.fulfill()
        }).ifFailed { error in
            print(error)
        }

        wait(for: [fetchExpectation], timeout: 10.0)
    }

    func testBasicNetworkFailure() {
        let url = URL(string: "http://some.thing.that.should.not.exist/failing")!
        let fetchExpectation = expectation(description: "This request should not work")

        var failed: Bool = false
        network.get(request: URLRequest(url: url), onFetched: { (result: TestAPIAnser?) in
            fetchExpectation.fulfill()
        }).ifFailed { error in
            failed = true
            fetchExpectation.fulfill()
            print(error)
        }

        waitForExpectations(timeout: 10.0) { error in
            XCTAssert(failed)
        }
    }

}
