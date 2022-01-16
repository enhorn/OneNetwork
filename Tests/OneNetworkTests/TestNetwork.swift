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

    var users: [User] = [] {
        willSet { objectWillChange.send() }
    }

    func fetchUsers(fail: Bool = false) {
        let path = fail ? "failing" : "users"
        let url = URL(string: "https://jsonplaceholder.typicode.com/\(path)")!
        get(request: URLRequest(url: url), onFetched: { [weak self] (users: [User]?) in
            guard let users = users else { return }
            self?.users = users
        })
    }

    func fetchUsersAsync(fail: Bool = false) async -> [User]? {
        let path = fail ? "failing" : "users"
        let url = URL(string: "https://jsonplaceholder.typicode.com/\(path)")!
        return await get(request: URLRequest(url: url))
    }

}
