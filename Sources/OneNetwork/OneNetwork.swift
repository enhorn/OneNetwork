//
//  Network.swift
//  Tricken 2
//
//  Created by Robin Enhorn on 2019-10-08.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

open class OneNetwork: ObservableObject {

    private let userAgent: String
    private let coder: Coder
    private let session: URLSession
    private let cache: NSCache<CacheKey, NSData>?

    internal var failureCallbacks: [UUID: (Error) -> Void] = [:]

    public let objectWillChange = PassthroughSubject<Void, Never>()

    /// Designated Initializer.
    /// - Parameter userAgent: Optional user agent. Defaults to iOS Safari user agent.
    /// - Parameter coder: Optional set of JSON enoder &  decoder. Defaults to a standard one with  date format `YYYY-MM-DD HH:mm`;
    /// - Parameter session: Optional URLSession. Defaults to `URLSession(configuration: .default)`.
    /// - Parameter cache: Optional NSCache. Defaults to `nil`.
    public init(userAgent: String? = nil, coder: Coder? = nil, session: URLSession? = nil, cache: NSCache<CacheKey, NSData>? = nil) {
        self.userAgent = userAgent ?? defaultUserAgent
        self.coder = coder ?? defaultCoder
        self.session = session ?? defaultURLSession
        self.cache = cache
    }

}

extension OneNetwork {

    func perform<T: Codable>(request: URLRequest, method: Method, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        var req = request

        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        req.httpMethod = method.stringValue

        switch method {
            case .get, .delete: break
            case .post(let parameters), .put(let parameters):
                if let params = try? parameters.flatMap(coder.encoder.encode) {
                    req.httpBody = params
                }
        }

        let cacheKey = CacheKey(for: request)
        if let value: T = cached(at: cacheKey) {
            resultQueue.async {
                onFetched(value)
            }
        } else {
            session.dataTask(with: req) { [weak self] data, _, error in
                if let error = error { self?.report(.other(originalError: error)); return }
                guard let data = data else { onFetched(nil); return }
                self?.cache?.setObject(data as NSData, forKey: cacheKey)
                self?.handle(data, resultQueue: resultQueue, onFetched: onFetched)
            }.resume()
        }

        return self
    }

}

private extension OneNetwork {

    func handle<T: Codable>(_ data: Data, resultQueue: DispatchQueue, onFetched: @escaping (T?) -> Void) {
        if let decoded: T = decode(from: data) {
            resultQueue.async {
                onFetched(decoded)
            }
        } else if let string = String(data: data, encoding: .utf8) {
            resultQueue.async {
                self.report(.unknownString(rawValue: string))
            }
        } else {
            resultQueue.async {
                self.report(.unparsableData(data: data))
            }
        }
    }

    func cached<T: Codable>(at key: CacheKey) -> T? {
        return cache?.object(forKey: key).flatMap({ decode(from: $0 as Data) })
    }

    func decode<T: Codable>(from data: Data) -> T? {
        try? self.coder.decoder.decode(T.self, from: data)
    }

    func report(_ error: Error) {
        failureCallbacks.forEach { key, callback in
            callback(error)
            failureCallbacks.removeValue(forKey: key)
        }
    }

}
