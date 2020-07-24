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

public typealias OneOauthLoginSuccess = (_ token: String) -> Void
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
            onLoggedIn: { token in
                onLoggedIn(token)
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
