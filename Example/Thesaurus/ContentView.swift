//
//  ContentView.swift
//  Thesaurus
//
//  Created by Robin Enhorn on 2019-12-21.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import SwiftUI
import OneNetwork

struct ContentView: View {

    @ObservedObject var network = Network(logger: Logger())

    @State var apiKey: String
    @State var query: String

    var body: some View {
        VStack {
            VStack {
                TextField("API Key", text: $apiKey, onEditingChanged: { _ in
                    UserDefaults.standard.set(self.apiKey, forKey: "thesaurus-api-key")
                })
                TextField("Search", text: $query, onEditingChanged: { _ in
                    self.network.define(self.query, apiKey: self.apiKey)
                })
            }
            List(network.definitions) { definition in
                VStack {
                    ForEach(definition.shortdef) { def in
                        Text(def)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apiKey: "abc-123", query: "A word")
    }
}
