//
//  Caches.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI
import OneNetwork

extension URL {

    var cacheKey: OneCacheKey {
        OneCacheKey(for: URLRequest(url: self))
    }

}

extension OneCache {

    static var login: OneCache {
        OneCache(
            key: URL.login.cacheKey,
            data: NSDataAsset(name: "login")!.data
        )
    }

    static var users: OneCache {
        OneCache(
            key: URL.users(token: .previewToken, page: 1).cacheKey,
            data: NSDataAsset(name: "users")!.data
        )
    }

}
