//
//  ContentView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-01.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var loginController: LoginController = LoginController()

    var body: some View {
        NavigationView {
            if self.loginController.isAuthenticated {
                UsersView(network: UsersNetwork(token: self.loginController.loginToken))
            } else {
                LoginView(loginController: loginController)
                    .navigationBarHidden(true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            loginController: LoginController(network: LoginNetwork(cache: .login))
        )
    }
}
