//
//  OneNetwork+Types.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

public extension OneNetwork {

    enum Error: Swift.Error {
        /// Returned data was an unparsable string.
        case unknownString(rawValue: String)

        /// Returned data was unparsable.
        case unparsableData(data: Data)

        /// Other type of error.
        case other(originalError: Swift.Error)
    }

    internal enum Method {

        case get
        case post(parameters: [String: String]?)
        case put(parameters: [String: String]?)
        case delete

        var stringValue : String {
            switch self {
                case .get: return "GET"
                case .post: return "POST"
                case .put: return "PUT"
                case .delete: return "DELETE"
            }
        }

    }

    /// Cache key for requests
    class CacheKey: NSObject {

        private let key: NSString

        /// Preferred initializer.
        /// - Parameter request: URLRequest this key should be based upon.
        init(for request: URLRequest) {
            self.key = String(request.hashValue) as NSString
        }

        public override func isEqual(_ object: Any?) -> Bool {
            guard let foreighKey = object as? CacheKey else { return false }
            return key == foreighKey.key
        }

    }

    /// Default encoder & decoder.
    struct Coder {
        let encoder: JSONEncoder
        let decoder: JSONDecoder
    }

}
