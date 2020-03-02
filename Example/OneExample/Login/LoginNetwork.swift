//
//  LoginNetwork.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

class LoginNetwork: OneNetwork {

    struct LoginResult: Codable {
        let token: LoginToken
    }

    func login(email: String, password: String, onLoggedIn: ((LoginToken) -> Void)? = nil, onFail: (() -> Void)? = nil) {
        post(
            request: URLRequest(url: .login),
            parameters: [
                "email": email,
                "password": password
            ],
            onFetched: { (result: LoginResult?) in
                if let token = result?.token {
                    onLoggedIn?(token)
                } else {
                    onFail?()
                }
            }
        ).ifFailed { error in
            onFail?()
        }
    }

}
