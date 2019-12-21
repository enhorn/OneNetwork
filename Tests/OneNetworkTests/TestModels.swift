//
//  TestModels.swift
//  OneNetworkTests
//
//  Created by Robin Enhorn on 2019-10-08.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation

struct User: Codable {

    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let company: Company

}

struct Address: Codable {

    let street: String
    let city: String
    let zipcode: String
    let geo: Location

}

struct Location: Codable {

    let lat: String
    let lng: String

}

struct Company: Codable {

    let name: String
    let catchPhrase: String

}
