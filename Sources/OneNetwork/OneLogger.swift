//
//  OneLogger.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

open class OneLogger {

    /// Log level for the default logger.
    public enum LogLevel: Int {

        /// Everything will be logged.
        case info

        /// Debug, Warning & Error will be logged.
        case debug

        /// Warning & Error will be logged.
        case warning

        /// Only Errors will be logged.
        case error

    }

    public static let standard = OneLogger()

    /// Current level of logging. Default is `.warning`.
    public var logLevel: LogLevel = .warning

    public func info(_ message: String) {
        guard logLevel.rawValue == LogLevel.info.rawValue else { return }
        print("ℹ️ \(message)")
    }

    public func debug(_ message: String) {
        guard logLevel.rawValue <= LogLevel.debug.rawValue else { return }
        print("🐛 \(message)")
    }

    public func warning(_ message: String) {
        guard logLevel.rawValue <= LogLevel.warning.rawValue else { return }
        print("⚠️ \(message)")
    }

    public func error(_ error: Error) {
        if let err = error as? OneNetwork.Error {
            switch err {
            case .unknownString(let rawValue):
                print("🚨 Unparsable JSON:")
                print(rawValue)
            case .unparsableData(let data):
                print("🚨 Unparsable Data:")
                print(data)
            case .invalidStatus(let code, let error, let data, let json):
                print("🚨 Invalid status code: \(code)")
                if let error = error { print(error) }
                if let data = data { print(data) }
                if let json = json { print(json) }
            case .other(let originalError):
                print("🚨 \(originalError)")
            }
        } else {
            print("🚨 \(error)")
        }
    }

}
