//
//  Helpers.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

extension URL {

    private static let baseURL = "https://reqres.in/api/"

    private static func endpoint(with path: String, token: LoginToken? = nil) -> URL {
        var urlString = baseURL + path

        if let token = token {
            urlString.append(contentsOf: "?token=\(token)")
        }

        return URL(string: urlString)!
    }

    static var login: URL {
        .endpoint(with: "login")
    }

    static func users(token: LoginToken) -> URL {
        .endpoint(with: "users", token: token)
    }

}
