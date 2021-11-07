//
//  LoginView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginView: View {

    @ObservedObject var loginController: LoginController

    @State private var email: String = "eve.holt@reqres.in"
    @State private var password: String = "somePassword"

    var body: some View {
        VStack(spacing: 32.0) {
            VStack {
                Text("Inser your credentials").font(.title)
                Text("(Any password)").foregroundColor(.secondary)
            }

            VStack(spacing: 16.0) {
                TextField("E-mail", text: $email)
                    .padding(12.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                SecureField("Password", text: $password)
                    .padding(12.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                Button(action: {
                    self.loginController.logIn(email: "eve.holt@reqres.in", password: "hopp")
                }, label: { Text("Log In") })
            }

            #if !targetEnvironment(macCatalyst)
            Text("or")

            Button(action: {
                self.loginController.logInWithOAuth()
            }, label: { Text("Log in with OAuth") })

            Button(action: {
                self.loginController.logInWithSpotifyOAuth()
            }, label: { Text("Log in to Spotify with OAuth") })
            #endif
        }.padding(16.0)
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            loginController: LoginController(network: LoginNetwork(cache: .login))
        )
    }
}
