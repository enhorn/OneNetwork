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
