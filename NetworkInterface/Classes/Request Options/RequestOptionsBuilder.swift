//
//  RequestOptionsBuilder.swift
//  NetworkInterface
//
//  Created by Christian Noon on 3/24/22.
//  Copyright © 2022 Nike. All rights reserved.
//

import Foundation

/// The request options builder class is a convenience type that uses the builder pattern to create a request options
/// instance. It offers an extensible, alternative API to the `RequestOptions` initializer allowing higher level
/// libraries to add convenience extensions for custom `RequestAttribute` instances.
public class RequestOptionsBuilder {
    struct RequestOptionsStorage {
        var validStatusCodes: [Int] = RequestOptions.defaultValidStatusCodes
        var redirectPolicy: RedirectPolicy?
        var cachedResponsePolicy: CachedResponsePolicy?
        var retryPolicies: [RetryPolicy] = [ConnectionLostRetryPolicy()]
        var interceptors: [Interceptor] = []
        var attributes: [String: RequestAttribute] = [:]
        var completionQueue: DispatchQueue = .main
    }

    var storage: RequestOptionsStorage

    /// Creates a `RequestOptionsBuilder` instance.
    public init() {
        self.storage = RequestOptionsStorage()
    }

    /// Sets the valid status codes for the `RequestOptions`.
    ///
    /// - Parameter statusCodes: The status codes.
    /// - Returns: The instance.
    @discardableResult
    public func validStatusCodes(_ statusCodes: [Int]) -> Self {
        storage.validStatusCodes = statusCodes
        return self
    }

    /// Sets the valid status codes for the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the status codes.
    /// - Returns: The instance.
    @discardableResult
    public func validStatusCodes(_ closure: () -> [Int]) -> Self {
        storage.validStatusCodes = closure()
        return self
    }

    /// Sets the redirect policy for the `RequestOptions`.
    ///
    /// - Parameter redirectPolicy: The redirect policy.
    /// - Returns: The instance.
    @discardableResult
    public func redirectPolicy(_ redirectPolicy: RedirectPolicy?) -> Self {
        storage.redirectPolicy = redirectPolicy
        return self
    }

    /// Sets the redirect policy for the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the redirect policy.
    /// - Returns: The instance.
    @discardableResult
    public func redirectPolicy(_ closure: () -> RedirectPolicy?) -> Self {
        storage.redirectPolicy = closure()
        return self
    }

    /// Sets the cached response policy for the `RequestOptions`.
    ///
    /// - Parameter cachedResponsePolicy: The cached response policy.
    /// - Returns: The instance.
    @discardableResult
    public func cachedResponsePolicy(_ cachedResponsePolicy: CachedResponsePolicy?) -> Self {
        storage.cachedResponsePolicy = cachedResponsePolicy
        return self
    }

    /// Sets the cached response policy for the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the cached response policy.
    /// - Returns: The instance.
    @discardableResult
    public func cachedResponsePolicy(_ closure: () -> CachedResponsePolicy?) -> Self {
        storage.cachedResponsePolicy = closure()
        return self
    }

    /// Adds a retry policy to the `RequestOptions`.
    ///
    /// - Parameter retryPolicy: The retry policy.
    /// - Returns: The instance.
    @discardableResult
    public func addRetryPolicy(_ retryPolicy: RetryPolicy?) -> Self {
        if let retryPolicy = retryPolicy { storage.retryPolicies.append(retryPolicy) }
        return self
    }

    /// Adds a retry policy to the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the retry policy.
    /// - Returns: The instance.
    @discardableResult
    public func addRetryPolicy(_ closure: () -> RetryPolicy?) -> Self {
        if let retryPolicy = closure() { storage.retryPolicies.append(retryPolicy) }
        return self
    }

    /// Adds the retry policies to the `RequestOptions`.
    ///
    /// - Parameter retryPolicies: The retry policies.
    /// - Returns: The instance.
    @discardableResult
    public func addRetryPolicies(_ retryPolicies: [RetryPolicy]?) -> Self {
        if let retryPolicies = retryPolicies { storage.retryPolicies.append(contentsOf: retryPolicies) }
        return self
    }

    /// Adds the retry policies to the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the retry policies.
    /// - Returns: The instance.
    @discardableResult
    public func addRetryPolicies(_ closure: () -> [RetryPolicy]?) -> Self {
        if let retryPolicies = closure() { storage.retryPolicies.append(contentsOf: retryPolicies) }
        return self
    }

    /// Adds the interceptor to the `RequestOptions`.
    ///
    /// - Parameter interceptor: The interceptor.
    /// - Returns: The instance.
    @discardableResult
    public func addInterceptor(_ interceptor: Interceptor?) -> Self {
        if let interceptor = interceptor { storage.interceptors.append(interceptor) }
        return self
    }

    /// Adds the interceptor to the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the interceptor.
    /// - Returns: The instance.
    @discardableResult
    public func addInterceptor(_ closure: () -> Interceptor?) -> Self {
        if let interceptor = closure() { storage.interceptors.append(interceptor) }
        return self
    }

    /// Adds the interceptors to the `RequestOptions`.
    ///
    /// - Parameter interceptors: The interceptors.
    /// - Returns: The instance.
    @discardableResult
    public func addInterceptors(_ interceptors: [Interceptor]?) -> Self {
        if let interceptors = interceptors { storage.interceptors.append(contentsOf: interceptors) }
        return self
    }

    /// Adds the interceptors to the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the interceptors.
    /// - Returns: The instance.
    @discardableResult
    public func addInterceptors(_ closure: () -> [Interceptor]?) -> Self {
        if let interceptors = closure() { storage.interceptors.append(contentsOf: interceptors) }
        return self
    }

    /// Sets the `RequestAttribute` for the specified key in the `RequestOptions`.
    ///
    /// - Parameters:
    ///   - attribute: The attribute.
    ///   - key: The key.
    ///
    /// - Returns: The instance.
    @discardableResult
    public func attribute(_ attribute: RequestAttribute?, forKey key: String) -> Self {
        storage.attributes[key] = attribute
        return self
    }

    /// Sets the `RequestAttribute` for the specified key in the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the key and `RequestAttribute`.
    /// - Returns: The instance.
    @discardableResult
    public func attribute(_ closure: () -> (String, RequestAttribute?)) -> Self {
        let attribute = closure()
        storage.attributes[attribute.0] = attribute.1
        return self
    }

    /// Sets the completion queue on the `RequestOptions`.
    ///
    /// - Parameter queue: The completion queue.
    /// - Returns: The instance.
    @discardableResult
    public func completionQueue(_ queue: DispatchQueue) -> Self {
        storage.completionQueue = queue
        return self
    }

    /// Sets the completion queue on the `RequestOptions`.
    ///
    /// - Parameter closure: The closure responsible for returning the completion queue.
    /// - Returns: The instance.
    @discardableResult
    public func completionQueue(_ closure: () -> DispatchQueue) -> Self {
        storage.completionQueue = closure()
        return self
    }

    /// Builds and returns the resulting `RequestOptions` instance.
    ///
    /// - Returns: The `RequestOptions` instance.
    public func build() -> RequestOptions {
        RequestOptions(
            validStatusCodes: storage.validStatusCodes,
            redirectPolicy: storage.redirectPolicy,
            cachedResponsePolicy: storage.cachedResponsePolicy,
            retryPolicies: storage.retryPolicies,
            interceptors: storage.interceptors,
            attributes: storage.attributes,
            completionQueue: storage.completionQueue
        )
    }
}
