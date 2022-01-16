//
//  File.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

// MARK: Async / Await API

public extension OneNetwork {

    /// GET request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - useCache: Whether or not to use any available cache. Defailt to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func get<T: Codable>(request: URLRequest, useCache: Bool = true, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            get(request: request, useCache: useCache, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - useCache: Whether or not to use any available cache. Defaults to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func post<T: Codable>(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            post(request: request, parameters: parameters, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func post<T: Codable>(request: URLRequest, parameters: [String: Parameter]?, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            post(request: request, parameters: parameters, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func put<T: Codable>(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            put(request: request, parameters: parameters, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func put<T: Codable>(request: URLRequest, parameters: [String: Parameter]?, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            put(request: request, parameters: parameters, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

    /// DELETE request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    func delete<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main) async -> T? {
        await withCheckedContinuation {
            delete(request: request, resultQueue: resultQueue, onFetched: $0.resume)
        }
    }

}

// MARK: Callback API

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
    ///   - useCache: Whether or not to use any available cache. Defaults to `true`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func post<T: Codable>(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .post(parameters: parameters?.typed()), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    @discardableResult
    func post(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main) -> Self {
        perform(request: request, method: .post(parameters: parameters?.typed()), resultQueue: resultQueue, onFetched: NullResponse.callback)
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func post<T: Codable>(request: URLRequest, parameters: [String: Parameter]?, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .post(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    @discardableResult
    func post(request: URLRequest, parameters: [String: Parameter]?, resultQueue: DispatchQueue = .main) -> Self {
        perform(request: request, method: .post(parameters: parameters), resultQueue: resultQueue, onFetched: NullResponse.callback)
    }

    /// POST request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    @discardableResult
    func post(request: URLRequest) -> Self {
        perform(request: request, method: .post(parameters: nil), resultQueue: .main, onFetched: NullResponse.callback)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func put<T: Codable>(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .put(parameters: parameters?.typed()), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    @discardableResult
    func put(request: URLRequest, parameters: [String: String]?, resultQueue: DispatchQueue = .main) -> Self {
        perform(request: request, method: .put(parameters: parameters?.typed()), resultQueue: resultQueue, onFetched: NullResponse.callback)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func put<T: Codable>(request: URLRequest, parameters: [String: Parameter]?, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .put(parameters: parameters), resultQueue: resultQueue, onFetched: onFetched)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - parameters: Parameters for the request. Defaults to `nil`.
    @discardableResult
    func put(request: URLRequest, parameters: [String: Parameter]?) -> Self {
        perform(request: request, method: .put(parameters: parameters), resultQueue: .main, onFetched: NullResponse.callback)
    }

    /// PUT request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    @discardableResult
    func put(request: URLRequest) -> Self {
        perform(request: request, method: .put(parameters: nil), resultQueue: .main, onFetched: NullResponse.callback)
    }

    /// DELETE request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    ///   - resultQueue: Which dispatch queue the result callback should be called on. Defaults to `.main`.
    ///   - onFetched: Result callback with result type decoded.
    @discardableResult
    func delete<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        perform(request: request, method: .delete, resultQueue: resultQueue, onFetched: onFetched)
    }

    /// DELETE request.
    /// - Parameters:
    ///   - request: URL request. Configured with any needed authentication.
    @discardableResult
    func delete(request: URLRequest) -> Self {
        perform(request: request, method: .delete, resultQueue: .main, onFetched: NullResponse.callback)
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
