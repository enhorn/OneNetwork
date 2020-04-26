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

    static var login: URL {
        .endpoint(with: "login")
    }

    // When authenticated by e-mail & password.
    static func users(token: LoginToken, page: Int) -> URL {
        return .endpoint(with: "users", token: token, params: [
            "page": String(page)
        ])
    }

    // When authenticated through OAuth.
    static func users(page: Int) -> URL {
        return .endpoint(with: "users", params: [
            "page": String(page)
        ])
    }

}

private extension URL {

    private static let baseURL = "https://reqres.in/api/"

    private static func endpoint(with path: String, token: LoginToken? = nil, params: [String:String]? = nil) -> URL {
        var components = URLComponents(string: baseURL)!
        var parameters: [URLQueryItem] = []

        components.path.append(path)

        if let token = token {
            parameters.append(.init(name: "token", value: token))
        }

        params?.forEach { key, value in
            parameters.append(.init(name: key, value: value))
        }

        if !parameters.isEmpty {
            components.queryItems = parameters
        }

        return components.url!
    }

}
