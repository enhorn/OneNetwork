//
//  OneCache.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

open class OneCache {

    typealias Cache = NSCache<OneCacheKey, NSData>

    private let cache: Cache = Cache()
    private var keys: Set<OneCacheKey> = []

    init(initialData:[OneCacheKey: Data] = [:]) {
        initialData.forEach { key, data in
            self.cacheData(data, for: key)
        }
    }

    func cacheData(_ data: Data, for key: OneCacheKey) {
        cache.setObject(data as NSData, forKey: key)
        keys.insert(key)
    }

    func cache(for key: OneCacheKey) -> Data? {
        return cache.object(forKey: key) as Data?
    }

    @discardableResult
    func removeCache(for key: OneCacheKey) -> Data? {
        let current = cache.object(forKey: key) as Data?
        cache.removeObject(forKey: key)
        keys.remove(key)
        return current
    }

    func hasValue(for key: OneCacheKey) -> Bool {
        return keys.contains(key)
    }

}
