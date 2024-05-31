//
//  DeferredRequest.swift
//  NetworkInterface
//
//  Created by Christian Noon on 3/30/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// Types adopting the `DeferredRequest` protocol can be used to safely construct `URLRequest`s.
public protocol DeferredRequest: Request {
    /// The HTTP method definitions. See [RFC 7231](http://tinyurl.com/hdbkd3q) for more info.
    var method: HTTPMethod { get }

    /// The base url string of the url (i.e. "https://api.nike.com").
    var baseURLString: String { get }

    /// Returns the relative path of the url.
    ///
    /// - Returns: The relative path of the url.
    /// - Throws: A `RequestError.initialization` when creating the path encounters an unrecoverable failure.
    func path() throws -> String

    /// Returns the query parameters to append to the url.
    ///
    /// - Returns: The query parameters to append to the url.
    /// - Throws: A `RequestError.initialization` if creating the query parameters encounters an unrecoverable failure.
    func queryParameters() throws -> QueryParameters

    /// Returns the http headers to append to the url request.
    ///
    /// - Returns: The http headers to append to the url request.
    /// - Throws: A `RequestError.initialization` if creating the headers encounters an unrecoverable failure.
    func headers() throws -> HTTPHeaders

    /// Returns the http body data and associated `Content-Type` header to append to the url request.
    ///
    /// - Returns: The http body and `Content-Type` header.
    /// - Throws: A `RequestError.initialization` if creating the body encounters an unrecoverable failure.
    func body() throws -> HTTPBody?

    /// Allows the urlRequest parameters to be modified before being sent to any adapters prior to execution.
    ///
    /// The request modifier is meant to give clients direct access to the underlying `URLRequest` immediately after
    /// being created, before it is sent off to the adapters. It is only meant to be a single use operation for the
    /// `DeferredRequest` it is attached to. It is not an async API, and is only intended to be used
    /// to set any remaining `URLRequest` APIs that are not directly exposed through the `DeferredRequest` protocol
    /// such as `timeoutInterval`, `cachePolicy`, `allowsCellularAccess`, etc. It should not be used to modify things
    /// that already exist in the `DeferredRequest` protocol like `httpMethod`,
    /// `httpBody`, etc.
    ///
    /// Another important note is that a request modifier IS NOT an interceptor, and should not be used as one. If you
    /// need to use custom interceptors to support custom authentication, or nested adapters, then you should use
    /// the `interceptors` property on `RequestOptions`.
    ///
    /// - Parameter urlRequest: The url request to be modified.
    /// - Throws: A `RequestError.initialization` if modifying the `URLRequest` encounters an unrecoverable failure.
    func requestModifier(_ urlRequest: inout URLRequest) throws
}

// MARK: -

extension DeferredRequest {
    /// Returns the query parameters to append to the url.
    ///
    /// - Returns: The query parameters to append to the url.
    /// - Throws: A `RequestError.initialization` if creating the query parameters encounters an unrecoverable failure.
    public func queryParameters() throws -> QueryParameters {
        [:]
    }

    /// Returns the http headers to append to the url request.
    ///
    /// - Returns: The http headers to append to the url request.
    /// - Throws: A `RequestError.initialization` if creating the headers encounters an unrecoverable failure.
    public func headers() throws -> HTTPHeaders {
        [:]
    }

    /// Returns the http body data and associated `Content-Type` header to append to the url request.
    ///
    /// - Returns: The http body and `Content-Type` header.
    /// - Throws: A `RequestError.initialization` if creating the body encounters an unrecoverable failure.
    public func body() throws -> HTTPBody? {
        nil
    }

    /// Allows the urlRequest parameters to be modified before being sent to any adapters prior to execution.
    ///
    /// The request modifier is meant to give clients direct access to the underlying `URLRequest` immediately after
    /// being created, before it is sent off to the adapters. It is only meant to be a single use operation for the
    /// `DeferredRequest` it is attached to. It is not an async API, and is only intended to be used
    /// to set any remaining `URLRequest` APIs that are not directly exposed through the `DeferredRequest` protocol
    /// such as `timeoutInterval`, `cachePolicy`, `allowsCellularAccess`, etc. It should not be used to modify things
    /// that already exist in the `DeferredRequest` protocol like `httpMethod`,
    /// `httpBody`, etc.
    ///
    /// Another important note is that a request modifier IS NOT an interceptor, and should not be used as one. If you
    /// need to use custom interceptors to support custom authentication, or nested adapters, then you should use
    /// the `interceptors` property on `RequestOptions`.
    ///
    /// - Parameter urlRequest: The url request to be modified.
    /// - Throws: A `RequestError.initialization` if modifying the `URLRequest` encounters an unrecoverable failure.
    public func requestModifier(_ urlRequest: inout URLRequest) throws {
        // No-op
    }

    /// Returns a `URLRequest` or throws if an `Error` was encoutered.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws: Any error thrown while constructing the `URLRequest`.
    /// - Throws: A `RequestError.initialization` if constructing the `URLRequest` encounters an unrecoverable failure.
    public func asURLRequest() throws -> URLRequest {
        let path = try self.path()
        let queryParameters = try self.queryParameters()
        let headers = try self.headers()
        let body = try self.body()

        let builder = RequestBuilder()
            .method(method)
            .baseURLString(baseURLString)
            .path(path)
            .queryParameterCharacterEscaping(queryParameters.characterEscaping)
            .addQueryParameters(queryParameters)
            .addHeaders(headers)

        body.flatMap { _ = builder.body($0) }

        let request = builder.build()
        var urlRequest = try request.asURLRequest()

        try requestModifier(&urlRequest)

        return urlRequest
    }
}
