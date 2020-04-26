//
//  UsersView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct UsersView: View {

    @ObservedObject var network: UsersNetwork

    var body: some View {
        List(network.users) { user in
            NavigationLink(
                destination: UserDetailsView(user: user),
                label: { UserListItemView(user: user) }
            ).onAppear {
                self.network.preloadAdjacentPages(to: user)
            }
        }.navigationBarTitle("Users")
            .onAppear { self.network.fetchIfNeeded(page: 1) }
    }

}

struct UsersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsersView(
                network: UsersNetwork(
                    token: .previewToken,
                    authentication: .none,
                    cache: .users
                )
            )
        }
    }
}
