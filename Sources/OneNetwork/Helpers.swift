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
