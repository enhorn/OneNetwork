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
    private let cache: OneCache?
    private let logger: OneLogger?

    internal var failureCallbacks: [UUID: (Error) -> Void] = [:]

    public let objectWillChange = PassthroughSubject<Void, Never>()

    /// Designated Initializer.
    /// - Parameter userAgent: Optional user agent. Defaults to iOS Safari user agent.
    /// - Parameter coder: Optional set of JSON enoder &  decoder. Defaults to a standard one with  date format `YYYY-MM-DD HH:mm`;
    /// - Parameter session: Optional URLSession. Defaults to `URLSession(configuration: .default)`.
    /// - Parameter cache: Optional OneCache. Defaults to `nil`.
    /// - Parameter logger: Optional OneLogger. Defaults to `nil`.
    public init(userAgent: String? = nil, coder: Coder? = nil, session: URLSession? = nil, cache: OneCache? = nil, logger: OneLogger? = nil) {
        self.userAgent = userAgent ?? defaultUserAgent
        self.coder = coder ?? defaultCoder
        self.session = session ?? defaultURLSession
        self.cache = cache
        self.logger = logger
    }

}

extension OneNetwork {

    func perform<T: Codable>(request: URLRequest, method: Method, resultQueue: DispatchQueue = .main, onFetched: @escaping (T?) -> Void) -> Self {
        let cacheKey = OneCacheKey(for: request)
        let type = String(describing: T.self)

        if method.useCache, let value: T = cached(at: cacheKey) {
            request.url.flatMap { logger?.info("Cached [\(type)]: \($0.absoluteString)") }
            resultQueue.async {
                onFetched(value)
            }
        } else {
            request.url.flatMap { logger?.info("Fetching [\(type)]: \($0.absoluteString)") }
            session.dataTask(with: configured(request, method: method)) { [weak self] data, _, error in
                if let error = error { self?.report(.other(originalError: error)); return }
                guard let data = data else { onFetched(nil); return }
                request.url.flatMap { self?.logger?.info("Fetched [\(type)]: \($0.absoluteString)") }
                if method.useCache { self?.cache?.cacheData(data, for: cacheKey) }
                self?.handle(data, resultQueue: resultQueue, onFetched: onFetched)
            }.resume()
        }

        return self
    }

    func perform(request: URLRequest, method: Method, resultQueue: DispatchQueue = .main, onFetched: @escaping ([NSDictionary]) -> Void) -> Self {
        let cacheKey = OneCacheKey(for: request)

        if method.useCache, let value: [NSDictionary] = cachedDict(at: cacheKey) {
            request.url.flatMap { logger?.info("Cached [NSDictionary]: \($0.absoluteString)") }
            resultQueue.async {
                onFetched(value)
            }
        } else {
            request.url.flatMap { logger?.info("Fetching [NSDictionary]: \($0.absoluteString)") }
            session.dataTask(with: configured(request, method: method)) { [weak self] data, _, error in
                if let error = error { self?.report(.other(originalError: error)); return }
                guard let data = data else { onFetched([]); return }
                request.url.flatMap { self?.logger?.info("Fetched [NSDictionary]: \($0.absoluteString)") }
                if method.useCache { self?.cache?.cacheData(data, for: cacheKey) }
                self?.handle(data, resultQueue: resultQueue, onFetched: onFetched)
            }.resume()
        }

        return self
    }

    private func configured(_ request: URLRequest, method: Method) -> URLRequest {
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

        return req
    }

}

private extension OneNetwork {

    func handle<T: Codable>(_ data: Data, resultQueue: DispatchQueue, onFetched: @escaping (T?) -> Void) {
        if let decoded: T = decode(from: data) {
            resultQueue.async {
                onFetched(decoded)
            }
        } else {
            handleError(data, resultQueue: resultQueue)
        }
    }

    func handle(_ data: Data, resultQueue: DispatchQueue, onFetched: @escaping ([NSDictionary]) -> Void) {
        if let parsed = parse(data) {
            resultQueue.async {
                onFetched(parsed)
            }
        } else {
            handleError(data, resultQueue: resultQueue)
        }
    }

    func handleError(_ data: Data, resultQueue: DispatchQueue) {
        if let string = String(data: data, encoding: .utf8) {
            resultQueue.async {
                self.report(.unknownString(rawValue: string))
            }
        } else {
            resultQueue.async {
                self.report(.unparsableData(data: data))
            }
        }
    }

    func report(_ error: Error) {
        failureCallbacks.forEach { key, callback in
            callback(error)
            failureCallbacks.removeValue(forKey: key)
            self.logger?.error(error)
        }
    }

}

private extension OneNetwork {

    func parse(_ data: Data) -> [NSDictionary]? {
        if let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] {
            return decoded
        } else if let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            return [decoded]
        } else {
            return nil
        }
    }

    func cachedDict(at key: OneCacheKey) -> [NSDictionary]? {
        guard let data = cache?.cache(for: key) else { return nil }
        return parse(data as Data)
    }

    func cached<T: Codable>(at key: OneCacheKey) -> T? {
        return cache?.cache(for: key).flatMap({ decode(from: $0) })
    }

    func decode<T: Codable>(from data: Data) -> T? {
        try? self.coder.decoder.decode(T.self, from: data)
    }

}

private extension OneNetwork.Method {

    var useCache: Bool {
        switch self {
        case .get(let useCache):
            return useCache
        case .post, .put, .delete:
            return false
        }
    }

}
