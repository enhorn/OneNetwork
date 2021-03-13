//
//  OneNetwork+Types.swift
//  
//
//  Created by Robin Enhorn on 2019-10-11.
//

import Foundation

public extension OneNetwork {

    /// Authentication status for the OneNetwork instance.
    enum AuthenticationStatus {

        /// The sessino has no special authentication set.
        case unauthenticated

        /// Authentication has a session, and if there is an expiry date, the authentication is still valid.
        case authenticated

        /// Authentication has expired.
        case expired

        /// Authentication is handled manually.
        case manual

    }

    /// Network authentication configuration.
    enum Authentication {

        /// No automatic authentication will be applied to requests.
        case none

        /// Bearer authentication will be applied to requests with the given session.
        case bearer(session: OauthSession)

        /// Custom authentication setup. Configure the request as needed.
        case custom(configure: (inout URLRequest) -> Void)

    }

    /// Network request parameter type.
    enum Parameter: Equatable, Encodable {

        /// String parameter.
        case string(String)

        /// Number parameter.
        case number(Int)

        /// Boolean parameter.
        case bool(Bool)

        /// An array of parameters.
        /// Not supported by `OnePostEncodingMethod.form` at this point.
        case array([Parameter])

        /// An array of parameters.
        /// Not supported by `OnePostEncodingMethod.form` at this point.
        case dictionary([String: Parameter])

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .number(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .bool(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .array(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .dictionary(let value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            }
        }

    }

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
        case post(parameters: [String: Parameter]?)
        case put(parameters: [String: Parameter]?)
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

        /// Encoder to use.
        public let encoder: JSONEncoder

        /// Decoder to use.
        public let decoder: JSONDecoder

        /// - Parameters:
        ///   - encoder: Encoder to use.
        ///   - decoder: Decoder to use.
        public init(encoder: JSONEncoder, decoder: JSONDecoder) {
            self.encoder = encoder
            self.decoder = decoder
        }
    }

}
