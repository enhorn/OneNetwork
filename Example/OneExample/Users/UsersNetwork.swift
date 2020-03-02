//
//  UsersNetwork.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

class UsersNetwork: OneNetwork {

    struct Result: Codable {

        enum CodingKeys: String, CodingKey {
            case page
            case perPage = "per_page"
            case totalPages = "total_pages"
            case total
            case users = "data"
        }

        let page: Int
        let perPage: Int
        let totalPages: Int
        let total: Int
        let users: [User]

    }

    @Published private(set) var users: [User] = [] {
        willSet { objectWillChange.send() }
    }

    private let token: LoginToken

    init(token: LoginToken, cache: OneCache? = nil) {
        self.token = token
        super.init(cache: cache)
    }

    func fetch() {
        get(request: URLRequest(url: .users(token: token))) { [weak self] (result: Result?) in
            self?.users = result?.users ?? []
        }
    }

}
