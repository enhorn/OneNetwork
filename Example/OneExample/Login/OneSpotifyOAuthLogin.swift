//
//  OneSpotifyOAuthLogin.swift
//  OneExample
//
//  Created by Robin Enhorn on 2021-01-29.
//  Copyright © 2021 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

#if canImport(UIKit) && canImport(AuthenticationServices)

import AuthenticationServices

public class OneSpotifyOAuthLogin: OneOAuthLogin {

    // APIs App Credentials
    private let clientID: String
    private let clientSecret: String
    private let urlScheme: String

    /// API scopes
    private let scopes: [String]

    /// Network for fetching access token
    private let network: SpotifyNetwork

    /// - Parameters:
    ///   - clientID: App Client ID.
    ///   - clientSecret: App Client Secret.
    ///   - urlScheme: App URL scheme.
    ///   - scopes: API scopes for the app.
    public init (clientID: String, clientSecret: String, urlScheme: String, scopes: [String]) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.urlScheme = urlScheme
        self.scopes = scopes
        self.network = SpotifyNetwork(clientID: clientID, clientSecret: clientSecret, urlScheme: urlScheme)
        super.init()
    }

    public override func start(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) {
        guard let url = url() else { return }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: urlScheme) { [weak self] url, error in
            if let url = url, let self = self {
                if
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                {
                    self.network.getAccessToken(code: code, onLoggedIn: { onLoggedIn($0.accessToken) }, onFail: onFail)
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
        var compontents = URLComponents(string: "https://accounts.spotify.com/authorize")

        compontents?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes.joined(separator: ",")),
            URLQueryItem(name: "redirect_uri", value: "\(urlScheme)://does.not.matter")
        ]

        return compontents?.url
    }

}

public struct SpotifyAccessResult: Codable {

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
    let refreshToken: SpotifyNetwork.Token

}

class SpotifyNetwork: OneNetwork {

    typealias Token = String
    typealias OnSuccess = (_ result: SpotifyAccessResult) -> Void
    typealias OnFail = (_ error: Error?) -> Void

    private let clientID: String
    private let clientSecret: String
    private let urlScheme: String

    var result: SpotifyAccessResult?
    var login: Date?

    var isExpired: Bool {
        guard let result = result, let login = login else { return true }
        return result.expiresIn >= Date().timeIntervalSince(login)
    }

    init(clientID: String, clientSecret: String, urlScheme: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.urlScheme = urlScheme
        super.init()
        self.authentication = .bearer(token: "\(clientID):\(clientSecret)".data(using: .utf8)!.base64EncodedString())
    }

    func getAccessToken(code: String, onLoggedIn: @escaping OnSuccess, onFail: @escaping OnFail) {
        post(
            request: URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!),
            parameters: [
                "code": code,
                "grant_type": "authorization_code",
                "redirect_uri": "\(urlScheme)://does.not.matter"
            ],
            onFetched: { [weak self] (result: SpotifyAccessResult?) in
                if let result = result {
                    self?.result = result
                    self?.login = Date()
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

    func deAuthenticate() {
        result = nil
        login = nil
    }

}

#endif
