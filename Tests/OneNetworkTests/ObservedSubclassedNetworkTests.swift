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
        testNetwork.translationAnswer = nil
        cancellable = nil
    }

    func testSubclassedAndObservedNetworkSuccess() {
        let query: String = "我的猫喜欢喝牛奶".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

        XCTAssertNil(testNetwork.translationAnswer)

        let fetchExpectation = expectation(description: "The fetched translation should be reported.")
        cancellable = testNetwork.objectWillChange.sink {
            fetchExpectation.fulfill()
        }

        testNetwork.fetchTranslation(query: query)

        waitForExpectations(timeout: 10.0) { error in
            XCTAssertNotNil(self.testNetwork.translationAnswer)
            XCTAssertEqual(self.testNetwork.translationAnswer?.text, "wǒ de māo xǐhuan hē niúnǎi")
        }
    }

    func testSubclassedAndObservedNetworkFailure() {
        let query: String = "this-should-fail"

        XCTAssertNil(testNetwork.translationAnswer)

        cancellable = testNetwork.objectWillChange.sink {
            XCTFail("This should not report an object change")
        }

        let fetchExpectation = expectation(description: "The fetched translation should not be reported.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: fetchExpectation.fulfill)

        testNetwork.fetchTranslation(query: query)
        wait(for: [fetchExpectation], timeout: 10.0)
    }

}
