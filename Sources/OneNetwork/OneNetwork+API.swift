//
//  File.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

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

    @discardableResult
    func ifFailed(_ callback: @escaping (Error) -> Void) -> UUID {
        let id = UUID()
        failureCallbacks[id] = callback
        return id
    }

}
