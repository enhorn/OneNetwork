//
//  LoginController.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-01.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

typealias LoginToken = String

extension LoginToken {
    static let invalidToken: String = "Invlid Token"
}

class LoginController: ObservableObject {

    enum Status {
        case ready
        case loggingIn
        case authenticated(token: LoginToken)
        case failed
    }

    private let network: LoginNetwork

    public let objectWillChange = PassthroughSubject<Void, Never>()

    private(set) var isAuthenticated: Bool = false {
        willSet { objectWillChange.send() }
    }

    private(set) var status: Status = .ready {
        willSet {
            objectWillChange.send()
            if case .authenticated(let token) = newValue {
                loginToken = token
                isAuthenticated = true
            } else {
                loginToken = .invalidToken
                isAuthenticated = false
            }
        }
    }

    private(set) var loginToken: LoginToken = .invalidToken

    init(network: LoginNetwork = LoginNetwork()) {
        self.network = network
    }

    func login(email: String, password: String) {
        status = .loggingIn
        network.login(
            email: email,
            password: password,
            onLoggedIn: { [weak self] token in
                self?.status = .authenticated(token: token)
            },
            onFail: { [weak self] in
                self?.status = .failed
            }
        )
    }

}
