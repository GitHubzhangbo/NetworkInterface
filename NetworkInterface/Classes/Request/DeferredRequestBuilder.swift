//
//  DeferredRequestBuilder.swift
//  NetworkInterface
//
//  Created by Christian Noon on 7/20/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// The deferred request builder class is a convenience type that uses the builder pattern to create a deferred request.
///
/// The deferred request builder should be used in cases where `path`, `QueryParameter`, `HTTPHeaders`, or `HTTPBody`
/// construction may encounter errors because you do not have all of the data encoded prior to creating the `Request`.
/// In these cases, developers should use either the `DeferredRequest` protocol or a `DeferredRequestBuilder` to
/// capture the potenially errors in closures that will be caught as part of the `URLRequest` creation process.
public class DeferredRequestBuilder {

    // MARK: - Typealiases

    /// A typealias representing various common base url strings as a convenience.
    public typealias BaseURLString = RequestBuilder.BaseURLString

    // MARK: - Properties

    var request: DefaultDeferredRequest

    // MARK: - Initialization

    /// Creates a new `DeferredRequestBuilder` instance.
    public init() {
        self.request = DefaultDeferredRequest()
    }

    // MARK: - Method

    /// Sets the method of the request.
    ///
    /// - Parameter method: The method.
    /// - Returns: The instance.
    @discardableResult
    public func method(_ method: HTTPMethod) -> Self {
        request.method = method
        return self
    }

    // MARK: - URL

    /// Sets the base url string of the request.
    ///
    /// - Parameter baseURLString: The base url string.
    /// - Returns: The instance.
    @discardableResult
    public func baseURLString(_ baseURLString: String) -> Self {
        request.baseURLString = baseURLString
        return self
    }

    /// Sets the base url string of the request.
    ///
    /// - Parameter baseURLString: The base url string.
    /// - Returns: The instance.
    @discardableResult
    public func baseURLString(_ baseURLString: BaseURLString) -> Self {
        request.baseURLString = baseURLString.rawValue
        return self
    }

    /// Sets the path of the request.
    ///
    /// - Parameter closure: The closure responsible for constructing the path.
    /// - Returns: The instance.
    @discardableResult
    public func path(_ closure: @escaping () throws -> String) -> Self {
        request.pathClosure = closure
        return self
    }

    // MARK: - Query Parameters

    /// Sets the query parameters of the request.
    ///
    /// - Parameter closure: The closure responsible for constructing the query parameters.
    /// - Returns: The instance.
    @discardableResult
    public func queryParameters(_ closure: @escaping () throws -> QueryParameters) -> Self {
        request.queryParametersClosure = closure
        return self
    }

    // MARK: - Headers

    /// Sets the headers of the request.
    ///
    /// - Parameter closure: The closure responsible for constructing the headers.
    /// - Returns: The instance.
    @discardableResult
    public func headers(_ closure: @escaping () throws -> HTTPHeaders) -> Self {
        request.headersClosure = closure
        return self
    }

    // MARK: - Body

    /// Sets the body of the request.
    ///
    /// - Parameter closure: The closure responsible for constructing the body.
    /// - Returns: The instance.
    @discardableResult
    public func body(_ closure: @escaping () throws -> HTTPBody) -> Self {
        request.bodyClosure = closure
        return self
    }

    /// Sets the body of the request by encoding the json value using the specified encoder.
    ///
    /// - Parameters:
    ///   - json:    The json value to encode.
    ///   - encoder: The json encoder.
    ///
    /// - Returns: The instance.
    @discardableResult
    public func body<T>(json: T, encoder: JSONEncoder = JSONEncoder()) -> Self where T: Encodable {
        request.bodyClosure = {
            let data = try encoder.encode(json)
            return EncodedBody(data: data, contentType: HTTPHeader.Value.ContentType.applicationJSON)
        }

        return self
    }

    // MARK: - Request Modifier

    /// Sets the request modifier of the request.
    ///
    /// - Parameter closure: The closure responsible for modifying the request.
    /// - Returns: The instance.
    @discardableResult
    public func requestModifier(_ closure: @escaping (inout URLRequest) throws -> Void) -> Self {
        request.requestModifierClosure = closure
        return self
    }

    // MARK: - Build

    /// Builds the request from all the request data.
    ///
    /// - Returns: The request.
    public func build() -> Request {
        request
    }
}

// MARK: -

struct DefaultDeferredRequest: DeferredRequest {
    var method: HTTPMethod = .get
    var baseURLString = ""
    var pathClosure: (() throws -> String)?
    var queryParametersClosure: (() throws -> QueryParameters)?
    var headersClosure: (() throws -> HTTPHeaders)?
    var bodyClosure: (() throws -> HTTPBody)?
    var requestModifierClosure: ((inout URLRequest) throws -> Void)?

    func path() throws -> String {
        guard !baseURLString.isEmpty else {
            let description = "Failed to create URL due to nil baseURLString"
            throw RequestError.initialization(.initializationFailed(description))
        }

        guard let pathClosure = pathClosure else {
            let description = "Failed to create URL due to nil path"
            throw RequestError.initialization(.initializationFailed(description))
        }

        return try pathClosure()
    }

    func queryParameters() throws -> QueryParameters {
        try queryParametersClosure?() ?? [:]
    }

    func headers() throws -> HTTPHeaders {
        try headersClosure?() ?? [:]
    }

    func body() throws -> HTTPBody? {
        try bodyClosure?()
    }

    func requestModifier(_ urlRequest: inout URLRequest) throws {
        try requestModifierClosure?(&urlRequest)
    }
}
