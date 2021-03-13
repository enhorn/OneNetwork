//
//  Helpers.swift
//  OneNetwork
//
//  Created by Robin Enhorn on 2019-10-08.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let date: DateFormatter = {
        let t = DateFormatter()
        t.dateFormat = "YYYY-MM-DD HH:mm"
        t.timeZone = .current
        return t
    }()

}

extension Dictionary where Key == String, Value == String {

    func typed() -> [String: OneNetwork.Parameter] {
        var values = [String: OneNetwork.Parameter]()
        for (key, value) in self {
            values[key] = .string(value)
        }
        return values
    }

}

struct NullResponse: Codable {

    static let callback = { (res: NullResponse?) in
        OneLogger.standard.info("Expected empty body returned.")
    }

}
