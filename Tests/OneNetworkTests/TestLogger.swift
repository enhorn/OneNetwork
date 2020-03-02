//
//  TestLogger.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import XCTest
@testable import OneNetwork

class TestLogger: OneLogger {

    var onInfo: (String) -> Void = { _ in }
    var onDebug: (String) -> Void = { _ in }
    var onError: (Error) -> Void = { _ in }

    override func info(_ message: String) {
        onInfo(message)
    }

    override func debug(_ message: String) {
        onDebug(message)
    }

    override func error(_ error: Error) {
        onError(error)
    }

}
