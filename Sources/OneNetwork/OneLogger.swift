//
//  OneLogger.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

open class OneLogger {

    public static let standard = OneLogger()

    public func info(_ message: String) {
        print("ℹ️ \(message)")
    }

    public func debug(_ message: String) {
        print("🐛 \(message)")
    }

    public func error(_ error: Error) {
        print("🚨 \(error)")
    }

}
