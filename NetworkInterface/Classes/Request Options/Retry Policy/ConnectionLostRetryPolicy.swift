//
//  ConnectionLostRetryPolicy.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A retry policy that automatically retries idempotent requests for network connection lost errors. For more
/// information about retrying network connection lost errors, please refer to Apple's
/// [technical document](https://developer.apple.com/library/content/qa/qa1941/_index.html).
public class ConnectionLostRetryPolicy: ExponentialBackoffRetryPolicy {
    /// Creates a `ConnectionLostRetryPolicy` instance from the specified parameters.
    ///
    /// - Parameters:
    ///   - retryLimit:              The total number of times the request is allowed to be retried.
    ///                              `RetryPolicy.defaultRetryLimit` by default.
    ///   - exponentialBackoffBase:  The base of the exponential backoff policy.
    ///                              `RetryPolicy.defaultExponentialBackoffBase` by default.
    ///   - exponentialBackoffScale: The scale of the exponential backoff.
    ///                              `RetryPolicy.defaultExponentialBackoffScale` by default.
    ///   - retryableHTTPMethods:    The idempotent http methods to retry.
    ///                              `RetryPolicy.defaultRetryableHTTPMethods` by default.
    public init(
        retryLimit: UInt = ExponentialBackoffRetryPolicy.defaultRetryLimit,
        exponentialBackoffBase: UInt = ExponentialBackoffRetryPolicy.defaultExponentialBackoffBase,
        exponentialBackoffScale: Double = ExponentialBackoffRetryPolicy.defaultExponentialBackoffScale,
        retryableHTTPMethods: Set<HTTPMethod> = ExponentialBackoffRetryPolicy.defaultRetryableHTTPMethods)
    {
        super.init(
            retryLimit: retryLimit,
            exponentialBackoffBase: exponentialBackoffBase,
            exponentialBackoffScale: exponentialBackoffScale,
            retryableHTTPMethods: retryableHTTPMethods,
            retryableHTTPStatusCodes: [],
            retryableURLErrorCodes: [.networkConnectionLost]
        )
    }
}
