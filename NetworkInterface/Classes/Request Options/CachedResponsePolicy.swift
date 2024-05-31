//
//  CachedResponsePolicy.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Defines the cached response policy for completed requests.
public enum CachedResponsePolicy {
    /// Stores the cached response in the cache.
    case cache

    /// Prevents the cached response from being stored in the cache.
    case doNotCache

    /// Modifies the cached response before storing it in the cache.
    case modify((URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?)
}
