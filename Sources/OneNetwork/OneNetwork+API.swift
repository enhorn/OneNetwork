//
//  File.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

// MARK: Auto Decoded Results

public extension OneNetwork {

    @discardableResult
    func get<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .get, resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func post<T: Codable>(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .post(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func put<T: Codable>(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .put(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func delete<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .delete, resultQueue: resultQueue, onFetched: onFetched)
    }

}

// MARK: JSON Dictionary Results

public extension OneNetwork {

    @discardableResult
    func get(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping ([NSDictionary]?) -> Void) -> Self {
        perform(request: request, method: .get, resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func post(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping ([NSDictionary]?) -> Void) -> Self {
        perform(request: request, method: .post(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func put(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping ([NSDictionary]?) -> Void) -> Self {
        perform(request: request, method: .put(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    @discardableResult
    func delete(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping ([NSDictionary]?) -> Void) -> Self {
        perform(request: request, method: .delete, resultQueue: resultQueue, onFetched: onFetched)
    }

}

// MARK: Error Handling

public extension OneNetwork {

    /// Add one-time failure callback.
    /// - Parameter callback: Callback to be called one if en error occurred.
    @discardableResult
    func ifFailed(_ callback: @escaping (Error) -> Void) -> UUID {
        let id = UUID()
        failureCallbacks[id] = callback
        return id
    }

}
