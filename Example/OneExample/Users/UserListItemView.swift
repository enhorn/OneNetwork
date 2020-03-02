//
//  UserListItemView.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct UserListItemView: View {

    let user: User

    var body: some View {
        HStack {
            user.image(size: 52.0, label: "Thumbnail")
            VStack(alignment: .leading) {
                Text(user.displayName).fontWeight(.medium)
                Text(user.email).foregroundColor(.secondary)
            }.padding(.horizontal, 8.0)
        }.padding(.vertical, 8.0)
    }

}

struct UserListItemView_Previews: PreviewProvider {

    static var previews: some View {
        UserListItemView(user: previewUser())
    }

    static func previewUser() -> User {
        try! JSONDecoder().decode(User.self, from: NSDataAsset(name: "user")!.data)
    }
    
}
