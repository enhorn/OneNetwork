//
//  Network.swift
//  Thesaurus
//
//  Created by Robin Enhorn on 2019-12-21.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

class Network: OneNetwork {

    let baseURL: String = "https://dictionaryapi.com/api/v3/references/thesaurus/json"

    var definitions: [Definition] = [] {
        willSet { objectWillChange.send() }
    }

    // You can get an API key here: https://dictionaryapi.com/products/api-collegiate-thesaurus
    func define(_ word: String, apiKey: String) {
        guard let query = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let url = URL(string: "\(baseURL)/\(query)?key=\(apiKey)")!
        definitions = []
        get(request: URLRequest(url: url), onFetched: { [weak self] definitions in
            self?.definitions = definitions ?? []
        })
    }

}

struct Definition: Identifiable, Codable {

    var id: String { meta.uuid }

    let shortdef: [String]
    let meta: Meta

}

struct Meta: Codable {

    let uuid: String
    let offensive: Bool
    let syns: [[String]]

}

extension String: Identifiable {
    public var id: String { self }
}
