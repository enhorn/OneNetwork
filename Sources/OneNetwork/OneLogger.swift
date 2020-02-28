//
//  OneLogger.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

public protocol OneLogger {
    func info(_ message: String)
    func debug(_ message: String)
    func error(_ error: Error)
}

public class OneBasicLogger: OneLogger {

    public static let standard = OneBasicLogger()

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
