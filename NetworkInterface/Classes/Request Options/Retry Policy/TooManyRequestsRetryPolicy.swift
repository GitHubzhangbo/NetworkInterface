//
//  TooManyRequestsRetryPolicy.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A retry policy that retries requests that receive a 429 status code. If a "Retry-After" header contains a
/// time delay in seconds, it will be used as the retry delay. Otherwise, the exponential backoff base and scale
/// will be used to create a fallback time delay.
public class TooManyRequestsRetryPolicy: RetryPolicy {

    // MARK: - Helper Types

    /// The backoff policy used as a fallback if the `Retry-After` header is missing in the response.
    ///
    /// - exponential: An exponential backoff using the base and scale.
    ///   - base:      The base of the exponential backoff policy (must be greater than or equal to 2).
    ///   - scale:     The scale of the exponential backoff (must be greater than 0).
    /// - doNotRetry:  No retries will be performed.
    public enum FallbackBackoffPolicy {
        case exponential(base: UInt, scale: Double)
        case doNotRetry
    }

    // MARK: - Properties

    /// The total number of times the request is allowed to be retried.
    public let retryLimit: UInt

    /// The maximum value allowed for the `Retry-After` header field the response.
    public let maxRetryAfterValueAllowed: UInt

    /// The backoff policy used as a fallback if the `Retry-After` header is missing in the response.
    public let fallbackBackoffPolicy: FallbackBackoffPolicy

    // MARK: - Initialization

    /// Creates a `TooManyRequestsRetryPolicy` from the specified parameters.
    ///
    /// - Parameters:
    ///   - retryLimit:                The total number of times the request is allowed to be retried. `2` by default.
    ///   - maxRetryAfterValueAllowed: The maximum value allowed for the `Retry-After` header field the response. `30`
    ///                                by default.
    ///   - fallbackBackoffPolicy:     The backoff policy to fall back on if the `Retry-After` header is
    ///                                missing. `.exponential(base: 2, scale: 0.5)` by default.
    public init(
        retryLimit: UInt = 2,
        maxRetryAfterValueAllowed: UInt = 30,
        fallbackBackoffPolicy: FallbackBackoffPolicy = .exponential(base: 2, scale: 0.5))
    {
        self.retryLimit = retryLimit
        self.maxRetryAfterValueAllowed = maxRetryAfterValueAllowed
        self.fallbackBackoffPolicy = fallbackBackoffPolicy
    }

    public func shouldRetry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        retryCount: Int,
        completion: @escaping (RetryResult) -> Void)
    {
        // Make sure the retry limit has not been met
        guard retryCount < retryLimit else { completion(.doNotRetry); return }

        // Identify the 429 status code
        guard let response = response, response.statusCode == 429 else { completion(.doNotRetry); return }

        let timeDelay: TimeInterval

        // Look for the "Retry-After" header field
        if let retryString = response.allHeaderFields[HTTPHeader.Field.retryAfter] as? String, let retryInt = Int(retryString) {
            if retryInt > maxRetryAfterValueAllowed {
                completion(.doNotRetry)
                return
            } else {
                timeDelay = TimeInterval(retryInt)
            }
        } else if case let .exponential(base, scale) = fallbackBackoffPolicy, base >= 2, scale > 0 {
            timeDelay = pow(Double(base), Double(retryCount)) * scale
        } else {
            completion(.doNotRetry)
            return
        }

        completion(.retryWithDelay(timeDelay))
    }
}
