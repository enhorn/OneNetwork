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
            Text("Inser your credentials").font(.title)
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
                    self.loginController.login(email: "eve.holt@reqres.in", password: "hopp")
                }, label: { Text("Log In") })
            }
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