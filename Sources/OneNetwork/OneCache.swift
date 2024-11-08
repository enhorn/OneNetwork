//
//  OneCache.swift
//  
//
//  Created by Robin Enhorn on 2019-10-15.
//

import Foundation

open class OneCache: NSObject {

    private let queue: DispatchQueue = DispatchQueue(label: "OneCacheQueue", qos: .background)

    fileprivate typealias Storage = [StorageKey: NSData]
    typealias Cache = NSCache<OneCacheKey, NSData>

    private let cache: Cache = Cache()
    private var storage: Storage = Storage()
    private var keys: Set<OneCacheKey> = []

    /// Designated Initializer.
    /// - Parameter initialData: Optional initial data to populate the cache with.
    /// - Parameter cacheLimit: Cache size limit. Meazured in MB. Defaults to 4 MB.
    public init(initialData:[OneCacheKey: Data] = [:], cacheLimit: UInt = 4) {
        super.init()
        self.cache.totalCostLimit = Int(cacheLimit * 1024 * 1024)
        self.cache.delegate = self
        initialData.forEach { key, data in
            self.cacheData(data, for: key)
        }
    }

    /// Convenience Initializer for default-populating a single cache key on init.
    /// - Parameter key: Key to cache.
    /// - Parameter data: Data that should be cached.
    /// - Parameter cacheLimit: Cache size limit. Meazured in MB. Defaults to 4 MB.
    public convenience init(key: OneCacheKey, data: Data, cacheLimit: UInt = 4) {
        self.init(initialData: [key: data], cacheLimit: cacheLimit)
    }

    /// Cache the given data at the key.
    /// - Parameter data: Data to be cached.
    /// - Parameter key: Key to be cached at.
    open func cacheData(_ data: Data, for key: OneCacheKey) {
        queue.sync {
            storage[StorageKey(data: data as NSData)] = data as NSData
            cache.setObject(data as NSData, forKey: key)
            keys.insert(key)
        }
    }

    /// Reteive cacked data for a goven key.
    /// - Parameter key: Key to fetch with.
    open func cache(for key: OneCacheKey) -> Data? {
        var data: NSData?

        queue.sync {
            data = cache.object(forKey: keys.first(where: { $0 == key }) ?? key)
        }

        return data as? Data
    }

    /// Remove cache fo the given key.
    /// - Parameter key: Key to remove cache for.
    @discardableResult
    open func removeCache(for key: OneCacheKey) -> Data? {
        var current: NSData?

        queue.sync {
            current = cache.object(forKey: key)
            cache.removeObject(forKey: key)
            keys.remove(key)
            if let current = current {
                storage.removeValue(forKey: StorageKey(data: current))
            }
        }

        return current as Data?
    }

    /// Remove all cached object.
    open func emptyCache() {
        queue.sync {
            storage.removeAll()
            cache.removeAllObjects()
            keys.removeAll()
        }
    }

    /// Get a dictionary representation of the current cache state.
    open func dictionaryRepresentation() -> [OneCacheKey: Data] {
        var dict = [OneCacheKey: Data]()

        queue.sync {
            for key in keys {
                if let data: NSData = cache.object(forKey: key) {
                    dict[key] = data as Data
                }
            }
        }

        return dict
    }

    /// Checks if the cache is currently storing a value for the key.
    /// - Parameter key: Key to check for cache with.
    open func hasValue(for key: OneCacheKey) -> Bool {
        var hasValue = false
        queue.sync {
            hasValue = keys.contains(key)
        }
        return hasValue
    }

}

extension OneCache: NSCacheDelegate {

    public func cache(_ cache: NSCache<OneCacheKey, NSData>, willEvictObject obj: NSData) {
        queue.sync {
            _ = storage.removeValue(forKey: StorageKey(data: obj))
        }
    }

}

// Don't waste RAM by keeping a copy of the data as Key.
private class StorageKey: NSObject {

    let dataHash: Int

    init(data: NSData) {
        self.dataHash = data.hashValue
    }

}
