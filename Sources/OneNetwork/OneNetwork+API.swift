//
//  File.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

// MARK: Auto Decoded Results

public extension OneNetwork {

    /// GET request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - useCache: Whether or not to use any available cache. Defailt to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func get<T: Codable>(request: URLRequest, useCache: Bool = true, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .get(useCache: useCache), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - useCache: Whether or not to use any available cache. Defailt to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func post<T: Codable>(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .post(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - useCache: Whether or not to use any available cache. Defailt to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func put<T: Codable>(request: URLRequest, parameters: [String: String]? = nil, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .put(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// DELETE request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - useCache: Whether or not to use any available cache. Defailt to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func delete<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
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
