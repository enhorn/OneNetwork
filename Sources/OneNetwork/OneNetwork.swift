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

public enum OnePostEncodingMethod {

    /// Will encode posted data as JSON.
    case json

    /// Will encode posted data as Form URL encoded.
    case form

    var type: String {
        switch self {
        case .json: return "application/json"
        case .form: return "application/x-www-form-urlencoded"
        }
    }

}

open class OneNetwork: ObservableObject {

    private let userAgent: String
    private let coder: Coder
    private let session: URLSession
    private let cache: OneCache?
    private let logger: OneLogger?
    private let encodingMethod: OnePostEncodingMethod

    internal var failureCallbacks: [UUID: (Error) -> Void] = [:]

    /// Authentication configuration.
    public var authentication: Authentication {
        didSet { isAuthenticated = authentication.isAuthenticated }
    }

    /// Published value for if the network is authenticated.
    @Published public var isAuthenticated: Bool {
        didSet { objectWillChange.send() }
    }

    public let objectWillChange = PassthroughSubject<Void, Never>()

    /// Designated Initializer.
    /// - Parameters:
    ///   - userAgent: Optional user agent. Defaults to iOS Safari user agent.
    ///   - coder: Optional set of JSON enoder &  decoder. Defaults to a standard one with  date format `YYYY-MM-DD HH:mm`;
    ///   - session: Optional URLSession. Defaults to `URLSession(configuration: .default)`.
    ///   - authentication: Authentication configuration. Defaults to `.none`.
    ///   - cache: Optional OneCache. Defaults to `nil`.
    ///   - logger: Optional OneLogger. Defaults to `.standard`.
    ///   - encodingMethod: Post encoding methos. Defaults to `.json`.
    public init(
        userAgent: String? = nil,
        coder: Coder? = nil,
        session: URLSession? = nil,
        authentication: Authentication = .none,
        cache: OneCache? = nil,
        logger: OneLogger? = .standard,
        encodingMethod: OnePostEncodingMethod = .json
    ) {
        self.userAgent = userAgent ?? defaultUserAgent
        self.coder = coder ?? defaultCoder
        self.session = session ?? defaultURLSession
        self.authentication = authentication
        self.cache = cache
        self.logger = logger
        self.encodingMethod = encodingMethod
        self.isAuthenticated = authentication.isAuthenticated
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
            let configuredRequest = configured(request, method: method)

            if let url = request.url {
                logger?.info("\(method.stringValue) START [\(type)]: \(url.absoluteString) \(logHeaders(request: configuredRequest))")
            }

            session.dataTask(with: configuredRequest) { [weak self] data, response, error in
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

                if let self = self, let url = request.url {
                    self.logger?.info("\(method.stringValue) DONE [\(type)]: \(url.absoluteString) \(self.logHeaders(request: configuredRequest))")
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
                guard let parameters = parameters, !parameters.isEmpty else { break }
                guard let data = postData(parameters: parameters) else {
                    logger?.debug("Could not encode parameters: \(parameters)")
                    break
                }
                req.httpBody = data
                req.setValue("\(encodingMethod.type); charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        switch authentication {
        case .none: ()
        case .bearer(let token):
            req.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        case .custom(let configure):
            configure(&req)
        }

        return req
    }

    private func postData(parameters: [String: String]) -> Data? {
        switch encodingMethod {
        case .json:
            return try? coder.encoder.encode(parameters)
        case .form:
            var body = ""

            for (key, value) in parameters {
                if let val = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    if !body.isEmpty { body.append("&") }
                    body.append("\(key)=\(val)")
                }
            }

            return body.data(using: .utf8)
        }
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

    func logHeaders(request: URLRequest) -> String {
        guard let headers = request.allHTTPHeaderFields, !headers.isEmpty else { return "" }

        let values: [String] = headers.keys.sorted().reduce([]) { current, key in
            guard let value = headers[key] else { return current }
            return current + ["\(key): \(value)"]
        }

        return "{ \(values.joined(separator: ", ")) }"
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

private extension OneNetwork.Authentication {

    var isAuthenticated: Bool {
        if case .none = self {
            return false
        } else {
            return true
        }
    }

}

extension HTTPURLResponse {

    var hasValidStatus: Bool {
        return (statusCode < 300) && (statusCode >= 200)
    }

}
