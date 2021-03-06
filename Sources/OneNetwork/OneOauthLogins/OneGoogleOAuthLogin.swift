//
//  OneGoogleOAuthLogin.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-04-05.
//  Copyright © 2020 Enhorn. All rights reserved.
//

#if os(iOS) && !os(watchOS) && canImport(AuthenticationServices)

import AuthenticationServices

public class OneGoogleOAuthLogin: OneOAuthLogin {

    // Google APIs App Credentials
    private let clientID: String
    private let urlScheme: String

    /// API scopes
    private let scopes: [String]

    /// - Parameters:
    ///   - clientID: App Client ID.
    ///   - urlScheme: App URL scheme.
    ///   - scopes: API scopes for the app.
    public init (clientID: String, urlScheme: String, scopes: [String]) {
        self.clientID = clientID
        self.urlScheme = urlScheme
        self.scopes = scopes
        super.init()
    }

    /// Start the login flow.
    /// - Parameters:
    ///   - onLoggedIn: Called when the authentication has succeeded.
    ///   - onFail: Called when the authentication has failed.
    public override func start(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        guard let url = url() else { return }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: urlScheme) { url, error in
            if let url = url {
                if
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                {
                    onLoggedIn(OneNetwork.OauthSession(accessToken: code))
                } else {
                    onFail(nil)
                }
            } else {
                onFail(error)
            }
        }

        session.presentationContextProvider = presentationProvider
        session.start()
    }

    private func url() -> URL? {
        var compontents = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")

        compontents?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: ",")),
            URLQueryItem(name: "redirect_uri", value: "\(urlScheme):/not.important.com")
        ]

        return compontents?.url
    }

}

#endif
