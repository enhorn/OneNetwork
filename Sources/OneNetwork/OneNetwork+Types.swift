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

        /// Returned status code was invalid. (<=200 or >=300)
        case invalidStatus(code: Int, error: Swift.Error?, data: Data?, json: String?)

        /// Other type of error.
        case other(originalError: Swift.Error)
    }

    internal enum Method: Equatable {

        case get(useCache: Bool = true)
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

    /// Default encoder & decoder.
    struct Coder {
        let encoder: JSONEncoder
        let decoder: JSONDecoder
    }

}
