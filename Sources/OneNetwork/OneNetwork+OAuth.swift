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

public typealias OneOauthLoginSuccess = (_ session: OneNetwork.OauthSession) -> Void
public typealias OneOauthLoginFail = (_ error: Error?) -> Void

private var oauthLogin: OneOAuthLogin?
extension OneNetwork {

    /// Session for OAuth logins.
    public struct OauthSession {

        /// Access token for the session.
        public let accessToken: String

        /// Refresh token for the session.
        public let refreshToken: String?

        /// Expiry date for the session.
        public let expiryDate: Date?

        /// - Parameters:
        ///   - accessToken: Access token for the session.
        ///   - refreshToken: Refresh token for the session. Defaults to `nil`.
        ///   - expiryDate: Expiry date for the session. Defaults to `nil`.
        public init(accessToken: String, refreshToken: String? = nil, expiryDate: Date? = nil) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiryDate = expiryDate
        }

    }

    /// - Parameters:
    ///   - login: OAuth login controller.
    ///   - onLoggedIn: Callback for when authentication succeeded..
    ///   - onFail: Callback for when authentication failed.
    public func authenticate(with login: OneOAuthLogin, onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        oauthLogin = login
        login.start(
            onLoggedIn: { session in
                self.authentication = .bearer(session: session)
                onLoggedIn(session)
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
