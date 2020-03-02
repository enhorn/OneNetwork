//
//  UserView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct UserDetailsView: View {

    let user: User

    var body: some View {
        VStack(spacing: 32.0) {
            HStack {
                user.image(size: 300, label: "User avatar")
                    .shadow(color: Color.gray, radius: 8, x: 0, y: 3)
            }
            VStack(spacing: 8.0) {
                Text(user.displayName).font(.title)
                Button(action: {
                    guard let url = URL(string: "mailto://\(self.user.email)") else { return}
                    UIApplication.shared.open(url)
                }, label: { Text(user.email) })
            }
            Spacer()
        }
    }

}

struct UserDetailsView_Previews: PreviewProvider {

    static var previews: some View {
        UserDetailsView(user: previewUser())
    }

    static func previewUser() -> User {
        try! JSONDecoder().decode(User.self, from: NSDataAsset(name: "user")!.data)
    }

}
