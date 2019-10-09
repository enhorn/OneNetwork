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

private let defaultUserAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1"
private let defaultDecoder: JSONDecoder = {
    let e = JSONDecoder()
    e.dateDecodingStrategy = .formatted(DateFormatter.date)
    return e
}()

public class OneNetwork: ObservableObject {

    public enum Error: Swift.Error {
        case unknownJSON(rawValue: String)
        case unparsableData(data: Data)
        case other(originalError: Swift.Error)
    }

    private var failureCallbacks: [UUID: (Error) -> Void] = [:]

    private let userAgent: String
    private let decoder: JSONDecoder
    private let session = URLSession(configuration: .default)

    public let objectWillChange = PassthroughSubject<Void, Never>()


    /// Designated Initializer.
    /// - Parameter userAgent: Optional user agent. Defaults to iOS Safari user agent.
    /// - Parameter decoder: Optional JSON decoder. Defaults to a standard one with a date encoder with date format `YYYY-MM-DD HH:mm`;
    public init(userAgent: String? = nil, decoder: JSONDecoder? = nil) {
        self.userAgent = userAgent ?? defaultUserAgent
        self.decoder = decoder ?? defaultDecoder
    }

    @discardableResult
    func fetch<T: Codable>(request: URLRequest, resultQueue: DispatchQueue = .main, onFetched: @escaping (T) -> Void) -> Self {
        var req = request
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: req) { [weak self] data, _, error in
            if let error = error { self?.report(.other(originalError: error)); return }
            guard let self = self, let data = data else { return }
            if let decoded = try? self.decoder.decode(T.self, from: data) {
                resultQueue.async {
                    onFetched(decoded)
                }
            } else if let string = String(data: data, encoding: .utf8) {
                resultQueue.async {
                    self.report(.unknownJSON(rawValue: string))
                }
                print(string)
            } else {
                resultQueue.async {
                    self.report(.unparsableData(data: data))
                }
            }
        }.resume()

        return self
    }

    @discardableResult
    func ifFailed(_ callback: @escaping (Error) -> Void) -> UUID {
        let id = UUID()
        failureCallbacks[id] = callback
        return id
    }

    private func report(_ error: Error) {
        failureCallbacks.forEach { key, callback in
            callback(error)
            failureCallbacks.removeValue(forKey: key)
        }
    }

}
