//
//  RetryPolicy.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A type that determines whether a request should be retried based on the server response and current retry count.
public protocol RetryPolicy {
    /// Determines whether a request should be retried or not based on the specified parameters.
    ///
    /// - Parameters:
    ///   - request:    The original request.
    ///   - error:      The error that occurred.
    ///   - response:   The server response.
    ///   - retryCount: The current retry count for the request.
    ///   - completion: The completion closure to call once the retry result has been determined.
    func shouldRetry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        retryCount: Int,
        completion: @escaping (RetryResult) -> Void)
}
