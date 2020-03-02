//
//  UserView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct UserView: View {

    let user: User

    var body: some View {
        VStack(spacing: 32.0) {
            HStack {
                LoadingImage(url: user.avatar, label: "User avatar", image: Image(systemName: "person.circle"))
                    .frame(width: 300, height: 300, alignment: .center)
                    .cornerRadius(150)
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

struct UserView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            UserView(user: previewUser())
        }
    }

    static func previewUser() -> User {
        try! JSONDecoder().decode(User.self, from: NSDataAsset(name: "user")!.data)
    }
}
