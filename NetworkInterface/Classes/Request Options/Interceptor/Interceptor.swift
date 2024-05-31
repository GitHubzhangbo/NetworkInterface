//
//  Interceptor.swift
//  NetworkInterface
//
//  Created by Christian Noon on 7/23/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A type that can inspect and adapt a url request as well as retry the request after encountering an error
/// if necessary.
public protocol Interceptor {
    /// Inspects and adapts the url request if necessary and calls the completion closure with a result type.
    ///
    /// - Parameters:
    ///   - urlRequest: The url request to potentially adapt.
    ///   - completion: The completion closure that must be called when adaptation is complete.
    func adapt(_ urlRequest: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void)

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
