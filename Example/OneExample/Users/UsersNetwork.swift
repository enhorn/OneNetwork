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

    struct Page: Codable {

        enum CodingKeys: String, CodingKey {
            case pageNumber = "page"
            case perPage = "per_page"
            case totalPages = "total_pages"
            case total
            case users = "data"
        }

        let pageNumber: Int
        let perPage: Int
        let totalPages: Int
        let total: Int
        let users: [User]

    }

    private var currentFetches: Set<Int> = []

    private var pages: [Page] = [] {
        didSet { updateUsersList() }
    }

    @Published private(set) var users: [User] = [] {
        willSet { objectWillChange.send() }
    }

    private let token: LoginToken

    init(token: LoginToken, cache: OneCache? = nil) {
        self.token = token
        super.init(cache: cache)
    }

    func fetchIfNeeded(page: Int) {
        guard !currentFetches.contains(page), !pages.contains(where: { $0.pageNumber == page }) else { return }
        currentFetches.insert(page)
        get(request: URLRequest(url: .users(token: token, page: page))) { [weak self] (result: Page?) in
            self?.currentFetches.remove(page)
            guard let page = result else { return }
            self?.pages.append(page)
        }.ifFailed { [weak self] _ in
            self?.currentFetches.remove(page)
        }
    }

    func preloadAdjacentPages(to user: User) {
        guard let page = page(holding: user) else { return }

        if let previous = page.previousPage {
            fetchIfNeeded(page: previous)
        }

        if let next = page.nextPage {
            fetchIfNeeded(page: next)
        }
    }

}

private extension UsersNetwork {

    func page(holding user: User) -> Page? {
        return pages.first { $0.users.contains(user) }
    }

    func updateUsersList() {
        users = pages.sorted(by: { $0.pageNumber < $1.pageNumber }).reduce([]) { current, page in
            return current + page.users
        }
    }

}

private extension UsersNetwork.Page {

    var previousPage: Int? {
        pageNumber > 1 ? pageNumber-1 : nil
    }

    var nextPage: Int? {
        pageNumber < totalPages ? pageNumber+1 : nil
    }

}
