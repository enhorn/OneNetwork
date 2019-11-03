//
//  OneCache.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

open class OneCache {

    typealias Cache = NSCache<OneCacheKey, NSData>

    private let lockQueue: DispatchQueue = DispatchQueue(label:"OneCache Lock Queue")
    private let cache: Cache = Cache()
    private var keys: Set<OneCacheKey> = []

    /// Designated Initializer.
    /// - Parameter initialData: Optional initial data to populate the cache with.
    public init(initialData:[OneCacheKey: Data] = [:]) {
        initialData.forEach { key, data in
            self.cacheData(data, for: key)
        }
    }

    /// Cache the given data at the key.
    /// - Parameter data: Data to be cached.
    /// - Parameter key: Key to be cached at.
    open func cacheData(_ data: Data, for key: OneCacheKey) {
        lockQueue.sync {
            cache.setObject(data as NSData, forKey: key)
            keys.insert(key)
        }
    }

    /// Reteive cacked data for a goven key.
    /// - Parameter key: Key to fetch with.
    open func cache(for key: OneCacheKey) -> Data? {
        var data: NSData?
        lockQueue.sync { data = cache.object(forKey: key) }
        return data as Data?
    }

    /// Remove cache fo the given key.
    /// - Parameter key: Key to remove cache for.
    @discardableResult
    open func removeCache(for key: OneCacheKey) -> Data? {
        var current: Data?

        lockQueue.sync {
            current = cache.object(forKey: key) as Data?
            cache.removeObject(forKey: key)
            keys.remove(key)
        }

        return current
    }

    /// Remove all cached object.
    open func emptyCache() {
        lockQueue.sync {
            cache.removeAllObjects()
            keys.removeAll()
        }
    }

    /// Get a dictionary representation of the current cache state.
    open func dictionaryRepresentation() -> [OneCacheKey: Data] {
        var result: [OneCacheKey: Data] = [:]

        lockQueue.sync {
            result = keys.reduce(result) { current, key in
                guard let data = cache(for: key) else { return current }
                var next = current
                next[key] = data
                return next
            }
        }

        return result
    }

    /// Checks if the cache is currently storing a value for the key.
    /// - Parameter key: Key to check for cache with.
    open func hasValue(for key: OneCacheKey) -> Bool {
        var result: Bool = false
        lockQueue.sync {
            result = keys.contains(key)
        }
        return result
    }

}
