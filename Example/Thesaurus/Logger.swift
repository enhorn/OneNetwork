//
//  Logger.swift
//  Thesaurus
//
//  Created by Robin Enhorn on 2019-12-21.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation
import OneNetwork

class Logger: OneLogger {

    func info(_ message: String) {
        print("ℹ️ \(message)")
    }

    func debug(_ message: String) {
        print("🐛 \(message)")
    }

    func error(_ error: Error) {
        print("🚨 \(error)")
    }

}
