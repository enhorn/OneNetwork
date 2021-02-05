//
//  OneSpotifyOAuthLogin.swift
//  OneExample
//
//  Created by Robin Enhorn on 2021-01-29.
//  Copyright © 2021 Enhorn. All rights reserved.
//

import Foundation

#if canImport(UIKit) && canImport(AuthenticationServices)

import AuthenticationServices

public class OneSpotifyOAuthLogin: OneOAuthLogin {

    // APIs App Credentials
    private let clientID: String
    private let clientSecret: String
    private let redirectURI: String

    /// API scopes
    private let scopes: [String]

    /// Network for fetching access token
    private let network: SpotifyNetwork

    /// - Parameters:
    ///   - clientID: App Client ID.
    ///   - clientSecret: App Client Secret.
    ///   - redirectURI: Redirect URI.
    ///   - authentication: Initial authentication information. Defaults to `.none`.
    ///   - scopes: API scopes for the app.
    public init (clientID: String, clientSecret: String, redirectURI: String, authentication: OneNetwork.Authentication = .none, scopes: [String]) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.scopes = scopes
        self.network = SpotifyNetwork(clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI, authentication: authentication)
        super.init()
    }

    /// Start the login flow.
    /// - Parameters:
    ///   - onLoggedIn: Called when the authentication has succeeded.
    ///   - onFail: Called when the authentication has failed.
    public override func start(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        guard let url = url(), let scheme = URL(string: redirectURI)?.scheme else { return }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { [weak self] url, error in
            if let url = url, let self = self {
                if
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                {
                    self.network.getAccessToken(code: code, onLoggedIn: {
                        onLoggedIn(OneNetwork.OauthSession(
                            accessToken: $0.accessToken,
                            refreshToken: $0.refreshToken,
                            expiryDate: Date(timeIntervalSinceNow: $0.expiresIn)
                        ))
                    }, onFail: onFail)
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

    /// Refreshes the access token.
    /// - Parameters:
    ///   - onRefresh: Called when token refresh has succeeded.
    ///   - onFail: Called when token refresh failed.
    public func refresh(onRefresh: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        network.refresh(onRefreshed: {
            onRefresh(OneNetwork.OauthSession(
                accessToken: $0.accessToken,
                refreshToken: $0.refreshToken,
                expiryDate: Date(timeIntervalSinceNow: $0.expiresIn)
            ))
        }, onFail: onFail)
    }


    /// Logs the newtwork out of the session.
    public func logOut() {
        network.deAuthenticate()
    }

    private func url() -> URL? {
        var compontents = URLComponents(string: "https://accounts.spotify.com/authorize")

        compontents?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: ",")),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]

        return compontents?.url
    }

}

private struct SpotifyAccessResult: Codable {

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }

    let accessToken: SpotifyNetwork.Token
    let tokenType: String
    let scope: String
    let expiresIn: TimeInterval
    var refreshToken: SpotifyNetwork.Token?

}

private class SpotifyNetwork: OneNetwork {

    typealias Token = String
    typealias OnSuccess = (_ result: SpotifyAccessResult) -> Void
    typealias OnFail = (_ error: Error?) -> Void

    private let clientID: String
    private let clientSecret: String
    private let redirectURI: String

    init(clientID: String, clientSecret: String, redirectURI: String, authentication: Authentication) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        super.init(authentication: authentication, encodingMethod: .form)
    }

    func getAccessToken(code: String, onLoggedIn: @escaping OnSuccess, onFail: @escaping OnFail) {
        post(
            request: URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!),
            parameters: [
                "code": code,
                "client_id": clientID,
                "client_secret": clientSecret,
                "grant_type": "authorization_code",
                "redirect_uri": redirectURI
            ],
            onFetched: { [weak self] (result: SpotifyAccessResult?) in
                if let result = result {
                    self?.setAuthentication(to: result)
                    onLoggedIn(result)
                } else {
                    self?.deAuthenticate()
                    onFail(nil)
                }
            }
        ).ifFailed { [weak self] error in
            self?.deAuthenticate()
            onFail(error)
        }
    }

    func refresh(onRefreshed: @escaping OnSuccess, onFail: @escaping OnFail) {
        guard case .bearer(session: let session) = authentication, let refreshToken = session.refreshToken else { return }
        guard let refreshAccessToken = "\(clientID):\(clientSecret)".data(using: .utf8)?.base64EncodedString() else { return }
        authentication = .bearer(session: OauthSession(accessToken: refreshAccessToken))

        post(
            request: URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!),
            parameters: [
                "refresh_token": refreshToken,
                "grant_type": "refresh_token"
            ],
            onFetched: { [weak self] (result: SpotifyAccessResult?) in
                if var result = result {
                    result.refreshToken = refreshToken
                    self?.setAuthentication(to: result)
                    onRefreshed(result)
                } else {
                    self?.deAuthenticate()
                    onFail(nil)
                }
            }
        ).ifFailed { [weak self] error in
            self?.deAuthenticate()
            onFail(error)
        }
    }

    func setAuthentication(to result: SpotifyAccessResult) {
        authentication = .bearer(
            session: OneNetwork.OauthSession(
                accessToken: result.accessToken,
                refreshToken: result.refreshToken,
                expiryDate: Date(timeIntervalSinceNow: result.expiresIn)
            )
        )
    }

    func deAuthenticate() {
        authentication = .none
    }

}

#endif
