//
//  OneNetwork+OAuth.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-04-05.
//  Copyright © 2020 Enhorn. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS) && canImport(AuthenticationServices)

import UIKit
import AuthenticationServices

public typealias OneOauthLoginSuccess = (_ token: String, _ refreshToken: String?, _ expiryDate: Date?) -> Void
public typealias OneOauthLoginFail = (_ error: Error?) -> Void

private var oauthLogin: OneOAuthLogin?
extension OneNetwork {

    /// - Parameters:
    ///   - login: OAuth login controller.
    ///   - onLoggedIn: Callback for when authentication succeeded..
    ///   - onFail: Callback for when authentication failed.
    public func authenticate(with login: OneOAuthLogin, onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        oauthLogin = login
        login.start(
            onLoggedIn: { token, refreshToken, expiryDate in
                onLoggedIn(token, refreshToken, expiryDate)
                oauthLogin = nil
            },
            onFail: { error in
                onFail(error)
                oauthLogin = nil
            }
        )
    }

}

#endif
