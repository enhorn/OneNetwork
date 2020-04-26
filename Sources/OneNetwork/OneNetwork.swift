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

    /// Authentication configuration.
    public var authentication: Authentication

    public let objectWillChange = PassthroughSubject<Void, Never>()

    /// Designated Initializer.
    /// - Parameter userAgent: Optional user agent. Defaults to iOS Safari user agent.
    /// - Parameter coder: Optional set of JSON enoder &  decoder. Defaults to a standard one with  date format `YYYY-MM-DD HH:mm`;
    /// - Parameter session: Optional URLSession. Defaults to `URLSession(configuration: .default)`.
    /// - Parameter authentication: Authentication configuration. Defaults to `.none`.
    /// - Parameter cache: Optional OneCache. Defaults to `nil`.
    /// - Parameter logger: Optional OneLogger. Defaults to `.standard`.
    public init(userAgent: String? = nil, coder: Coder? = nil, session: URLSession? = nil, authentication: Authentication = .none, cache: OneCache? = nil, logger: OneLogger? = .standard) {
        self.userAgent = userAgent ?? defaultUserAgent
        self.coder = coder ?? defaultCoder
        self.session = session ?? defaultURLSession
        self.authentication = authentication
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
            request.url.flatMap { logger?.info("\(method.stringValue) START [\(type)]: \($0.absoluteString)") }
            session.dataTask(with: configured(request, method: method)) { [weak self] data, response, error in
                if let httpResponse = response as? HTTPURLResponse, !httpResponse.hasValidStatus {
                    self?.report(.invalidStatus(
                        code: httpResponse.statusCode,
                        error: error,
                        data: data,
                        json: data.flatMap { String.init(data: $0, encoding: .utf8) }
                    ))
                    return
                }

                if let error = error {
                    self?.report(.other(originalError: error))
                    return
                }

                guard let data = data else { resultQueue.async { onFetched(nil) }; return }

                if let url = request.url {
                    self?.logger?.info("\(method.stringValue) DONE [\(type)]: \(url.absoluteString)")
                }

                if method.useCache {
                    self?.cache?.cacheData(data, for: cacheKey)
                }

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
                guard let parameters = parameters else { break }
                guard let params = try? coder.encoder.encode(parameters) else {
                    logger?.debug("Could not encode parameters: \(parameters)")
                    break
                }
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = params
        }

        switch authentication {
        case .none: ()
        case .bearer(let token):
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .custom(let configure):
            configure(request)
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
        logger?.error(error)
        failureCallbacks.forEach { key, callback in
            callback(error)
            failureCallbacks.removeValue(forKey: key)
        }
    }

}

private extension OneNetwork {

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

extension HTTPURLResponse {

    var hasValidStatus: Bool {
        return (statusCode < 300) && (statusCode >= 200)
    }

}
