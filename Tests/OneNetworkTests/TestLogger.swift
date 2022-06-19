//
//  TestLogger.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import XCTest
import OneLogger
@testable import OneNetwork

class TestLogger: OneLogger {

    var level: OneLogLevel = .info

    var onInfo: (String) -> Void = { _ in }
    var onDebug: (String) -> Void = { _ in }
    var onWarning: (String) -> Void = { _ in }
    var onError: (Error) -> Void = { _ in }

    func info(_ message: String) {
        onInfo(message)
    }

    func debug(_ message: String) {
        onDebug(message)
    }

    func warning(_ message: String) {
        onWarning(message)
    }

    func error(_ error: Error) {
        onError(error)
    }

}
