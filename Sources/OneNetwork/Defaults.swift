//
//  Defaults.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

let defaultUserAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1"

let defaultCoder = OneNetwork.Coder(
    encoder: {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .formatted(DateFormatter.date)
        return e
    }(),
    decoder: {
        let e = JSONDecoder()
        e.dateDecodingStrategy = .formatted(DateFormatter.date)
        return e
    }()
)

let defaultURLSession = URLSession(configuration: .default)
