//
//  TestNetwork.swift
//  OneNetworkTests
//
//  Created by Robin Enhorn on 2019-10-08.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation
@testable import OneNetwork

class TestNetwork: OneNetwork {

    var translationAnswer: TestAPIAnser? = nil {
        willSet { objectWillChange.send() }
    }

    func fetchTranslation(query: String) {
        let url = URL(string: "https://api.pinyin.pepe.asia/pinyin/\(query)")!
        get(request: URLRequest(url: url), onFetched: { [weak self] (answer: TestAPIAnser?) in
            self?.translationAnswer = answer
        })
    }

}
