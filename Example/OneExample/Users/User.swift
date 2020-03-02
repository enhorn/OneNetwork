//
//  User.swift
//  OneExample
//
//  Created by Robin Enhorn on 2020-03-02.
//  Copyright © 2020 Enhorn. All rights reserved.
//

import Foundation

struct User: Codable, Identifiable {

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

    var displayName: String {
        [firstName, lastName].joined(separator: " ")
    }

}
