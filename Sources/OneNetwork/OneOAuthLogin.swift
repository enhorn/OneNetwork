//
//  OneOAuthLogin.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-04-05.
//  Copyright © 2020 Enhorn. All rights reserved.
//

#if canImport(UIKit) && canImport(AuthenticationServices)

import UIKit
import AuthenticationServices

open class OneOAuthLogin {

    public lazy var presentationProvider = OAuthPresentationViewController()

    /// Override this to build own OAuth implementations.
    open func start(onLoggedIn: @escaping OneOauthLoginSuccess, onFail: @escaping OneOauthLoginFail) { }

}

public class OAuthPresentationViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window: UIWindow? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter {
                $0.activationState == .foregroundActive &&
                $0.windows.contains { $0.isKeyWindow }
            }
            .first?.windows.first { $0.isKeyWindow }

        return window ?? ASPresentationAnchor()
    }

}

#endif
