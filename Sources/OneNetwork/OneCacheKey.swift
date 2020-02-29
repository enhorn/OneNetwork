//
//  OneCacheKey.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

/// Cache key for requests
public class OneCacheKey: NSObject, RawRepresentable {

    public typealias RawValue = String

    private let key: NSString

    /// Preferred initializer.
    /// - Parameter request: URLRequest this key should be based upon.
    public init(for request: URLRequest) {
        let string = request.url?.absoluteString ?? String(request.hashValue)
        self.key = string as NSString
    }

    /// Custom initilizer for a raw value representation of the key.
    /// - Parameter rawValue: Raw String value representation of the key.
    public required init(rawValue: String) {
        self.key = NSString(string: rawValue)
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let foreighKey = object as? OneCacheKey else { return false }
        return key == foreighKey.key
    }

    public var rawValue: String { String(key) }

}
