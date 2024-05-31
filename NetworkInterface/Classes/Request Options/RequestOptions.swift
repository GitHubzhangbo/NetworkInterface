//
//  RequestOptions.swift
//  NetworkInterface
//
//  Created by Christian Noon on 2/23/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// The request options type is a container that stores all the runtime behavior for the request lifecycle. It contains
/// information such as valid status codes, authentication, retry policies, redirect policies, custom tags, and the
/// completion queue to call once the request completes.
public struct RequestOptions {
    /// The default status codes considered to be valid for most requests. Please refer to the
    /// [Mozilla docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#successful_responses) for more
    /// information about successful status codes.
    public static let defaultValidStatusCodes = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]

    /// The authentication type to use when executing the request. If you do not need to authenticate the request, or
    /// the authentication is already built into the request, set the authentication to `nil`.
    public let authentication: Authentication?

    /// The acceptable HTTP status codes for the `HTTPURLResponse`. If the server returns an invalid status code, then
    /// a status code validation error will always be returned in the result.
    ///
    /// If you need to parse service failures out of the JSON payload for certain 4XX or 5XX status codes, make sure to
    /// list them as valid status codes as well.
    public let validStatusCodes: [Int]

    /// The redirect policy used to determine what to do when a redirect response is received from the server.
    public let redirectPolicy: RedirectPolicy?

    /// The cached response policy used to determine whether to cache or modify a cached response for a request prior
    /// to appending it to the url cache.
    public let cachedResponsePolicy: CachedResponsePolicy?

    /// The retry policies to execute when the request execution for the endpoint encounters an error.
    public let retryPolicies: [RetryPolicy]

    /// The interceptors used to adapt the url request and retry the request if necessary.
    ///
    /// In general, these should be used as a last resort, since `Authentication` and `retryPolicies` should handle
    /// almost every use case. However, if you need to build a custom authentication system, or layer together multiple
    /// complex adapters, this is the best option.
    ///
    /// Any interceptors provided will be the last in the retry chain. The retry chain is evaluated as:
    ///
    ///   1) Any retry policies in the order provided
    ///   2) The authentication if provided
    ///   3) Any interceptors in the order provided
    public let interceptors: [Interceptor]

    /// The dictionary of attributes associated with the request that are not handled directly by the implementation.
    /// Request attributes are intended to be used by Network Plugins.
    public let attributes: [String: RequestAttribute]

    /// The tags to apply to the request.
    public let tags: Set<Tag>

    /// The dispatch queue the completion closure is executed on when the request is complete.
    public let completionQueue: DispatchQueue

    /// Creates a `RequestOptions` instance from the specified parameters.
    ///
    /// - Parameters:
    ///   - authentication:       The authentication.
    ///   - validStatusCodes:     The valid status codes.
    ///   - redirectPolicy:       The redirect policy.
    ///   - cachedResponsePolicy: The cached response policy.
    ///   - retryPolicies:        The retry policies. `[ConnectionLostRetryPolicy()]` by default.
    ///   - interceptors:         The interceptors. `[]` by default.
    ///   - attributes:           The request attributes. `[:]` by default.
    ///   - tags:                 The tags.
    ///   - completionQueue:      The dispatch queue to execute the completion closure on when the request completes.
    public init(
        authentication: Authentication? = nil,
        validStatusCodes: [Int] = RequestOptions.defaultValidStatusCodes,
        redirectPolicy: RedirectPolicy? = nil,
        cachedResponsePolicy: CachedResponsePolicy? = nil,
        retryPolicies: [RetryPolicy] = [ConnectionLostRetryPolicy()],
        interceptors: [Interceptor] = [],
        attributes: [String: RequestAttribute] = [:],
        tags: Set<Tag> = [],
        completionQueue: DispatchQueue = .main)
    {
        self.authentication = authentication
        self.validStatusCodes = validStatusCodes
        self.redirectPolicy = redirectPolicy
        self.cachedResponsePolicy = cachedResponsePolicy
        self.retryPolicies = retryPolicies
        self.interceptors = interceptors
        self.attributes = attributes
        self.tags = tags
        self.completionQueue = completionQueue
    }
}
