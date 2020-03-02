//
//  User.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI

struct User: Codable, Identifiable, Equatable {

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }

    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: URL

}

extension User {

    var displayName: String {
        [firstName, lastName].joined(separator: " ")
    }

    func image(size: CGFloat, label: String) -> some View {
        LoadingImage(
            url: avatar,
            label: label,
            image: Image(systemName: "person.circle")
        )
        .frame(width: size, height: size, alignment: .center)
        .cornerRadius(size / 2.0)
    }

}
