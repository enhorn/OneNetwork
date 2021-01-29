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

    typealias OnLoginSuccess = (_ token: LoginToken) -> Void
    typealias OnLoginFail = (_ error: Error?) -> Void

    struct LoginResult: Codable {
        let token: LoginToken
    }

    func logIn(email: String, password: String, onLoggedIn: @escaping OnLoginSuccess, onFail: @escaping OnLoginFail) {
        post(
            request: URLRequest(url: .login),
            parameters: [
                "email": email,
                "password": password
            ],
            onFetched: { (result: LoginResult?) in
                if let token = result?.token {
                    onLoggedIn(token)
                } else {
                    onFail(nil)
                }
            }
        ).ifFailed { error in
            onFail(error)
        }
    }

    func logInWithOAuth(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        authenticate(
            with: OneGoogleOAuthLogin(
                clientID: "",
                urlScheme: "",
                scopes: [""]
            ),
            onLoggedIn: onLoggedIn,
            onFail: onFail
        )
    }

    func logInWithSpotifyOAuth(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        authenticate(
            with: OneSpotifyOAuthLogin(
                clientID: "",
                clientSecret: "",
                urlScheme: "onespot",
                scopes: ["user-library-read"]
            ),
            onLoggedIn: onLoggedIn,
            onFail: onFail
        )
    }

}


