//
//  RequestBuilder.swift
//  NetworkInterface
//
//  Created by Christian Noon on 2/26/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// The request builder class is a convenience type that uses the builder pattern to create a request. It
/// should only be used when all the data required to create a request has already been safely assembled. If it
/// has not been safely assembled and request creation can fail, please use the `DeferredRequest` type.
///
/// The request builder is an alternative API to use instead of `URLRequest`. It supports chaining as well as
/// many `NetworkInterface` convenience types.
public class RequestBuilder {

    // MARK: - Helper Types

    /// Represents various common base url strings as a convenience.
    public struct BaseURLString: RawRepresentable {
        /// The base url string for "api.nike.com".
        public static let apiNikeCom = BaseURLString(rawValue: "https://api.nike.com")

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    // MARK: - Properties

    var request: DefaultRequest

    // MARK: - Initialization

    /// Creates a new `RequestBuilder` instance.
    public init() {
        self.request = DefaultRequest()
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
    /// - Parameter path: The path.
    /// - Returns: The instance.
    @discardableResult
    public func path(_ path: String) -> Self {
        request.path = path
        return self
    }

    // MARK: - Query Parameters

    /// Sets the character escaping type for the query parameters added to the request.
    ///
    /// - Parameter characterEscaping: The character escaping to use for query parameters.
    /// - Returns: The instance.
    @discardableResult
    public func queryParameterCharacterEscaping(_ characterEscaping: QueryParameters.CharacterEscaping) -> Self {
        request.queryParameters.characterEscaping = characterEscaping
        return self
    }

    /// Adds the query parameter to the request.
    ///
    /// - Parameters:
    ///   - name:  The name of the query parameter.
    ///   - value: The value of the query parameter.
    ///
    /// - Returns: The instance.
    @discardableResult
    public func addQueryParameter(name: String, value: String) -> Self {
        request.queryParameters += (name, value)
        return self
    }

    /// Adds the query parameters to the request.
    ///
    /// - Parameter queryParameters: The query parameters.
    /// - Returns: The instance.
    @discardableResult
    public func addQueryParameters(_ queryParameters: QueryParameters) -> Self {
        request.queryParameters += queryParameters
        return self
    }

    // MARK: - Headers

    /// Adds the header to the request.
    ///
    /// - Parameters:
    ///   - name: The name of the header.
    ///   - value: The value of the header.
    ///
    /// - Returns: The instance.
    @discardableResult
    public func addHeader(name: String, value: String) -> Self {
        request.headers.add(name: name, value: value)
        return self
    }

    /// Adds the header to the request.
    ///
    /// - Parameter header: The header.
    /// - Returns: The instance.
    @discardableResult
    public func addHeader(_ header: HTTPHeader) -> Self {
        request.headers.add(header)
        return self
    }

    /// Adds the headers to the request.
    ///
    /// - Parameter headers: The headers.
    /// - Returns: The instance.
    @discardableResult
    public func addHeaders(_ headers: HTTPHeaders) -> Self {
        headers.forEach { request.headers.add($0) }
        return self
    }

    // MARK: - Body

    /// Sets the body on the request.
    ///
    /// - Parameter body: The body.
    /// - Returns: The instance.
    @discardableResult
    public func body(_ body: HTTPBody) -> Self {
        request.setBody(body)
        return self
    }

    // MARK: - Request Modifier

    /// Sets the request modifier on the request.
    ///
    /// - Parameter requestModifier: The request modifier.
    /// - Returns: The instance.
    @discardableResult
    public func requestModifier(_ requestModifier: @escaping (inout URLRequest) throws -> Void) -> Self {
        request.requestModifier = requestModifier
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

struct DefaultRequest: Request {
    var method: HTTPMethod?
    var baseURLString: String?
    var path: String?
    var queryParameters: QueryParameters = [:]
    var headers: HTTPHeaders = [:]
    var body: Data?
    var requestModifier: ((inout URLRequest) throws -> Void)?

    mutating func setBody(_ body: HTTPBody) {
        self.body = body.data
        self.headers.add(name: HTTPHeader.Field.contentType, value: body.contentType)
    }

    func asURLRequest() throws -> URLRequest {
        let url = try makeURL()
        var urlRequest = try makeURLRequest(with: url)

        if let requestModifier = requestModifier {
            try requestModifier(&urlRequest)
        }

        return urlRequest
    }

    func makeURL() throws -> URL {
        guard let baseURLString = baseURLString else {
            let description = "Failed to create URL due to nil baseURLString"
            throw RequestError.initialization(.initializationFailed(description))
        }

        guard let path = path else {
            let description = "Failed to create URL due to nil path"
            throw RequestError.initialization(.initializationFailed(description))
        }

        var urlString = baseURLString + path

        if let queryString = try queryParameters.queryString() {
            urlString += "?\(queryString)"
        }

        guard let url = URL(string: urlString) else {
            throw RequestError.initialization(.initializationFailed("Invalid URL: \(urlString)"))
        }

        return url
    }

    func makeURLRequest(with url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)

        method.flatMap { urlRequest.method = $0 }
        urlRequest.headers = headers
        urlRequest.httpBody = body

        return urlRequest
    }
}
