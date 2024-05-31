//
//  HTTPHeaders.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// An order-preserving and case-insensitive representation of HTTP headers.
public struct HTTPHeaders {
    /// The dictionary representation of all headers.
    ///
    /// This representation does not preserve the current order of the instance.
    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }

        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }

    private var headers: [HTTPHeader] = []

    /// Creates an empty instance.
    public init() {}

    /// Creates an instance from an array of `HTTPHeader`s. Duplicate case-insensitive names are collapsed into the last
    /// name and value encountered.
    public init(_ headers: [HTTPHeader]) {
        self.init()
        headers.forEach { update($0) }
    }

    /// Creates an instance from a `[String: String]`. Duplicate case-insensitive names are collapsed into the last name
    /// and value encountered.
    public init(_ dictionary: [String: String]) {
        self.init()
        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }

    /// Case-insensitively access the header with the given name.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }

    /// Case-insensitively updates or appends an `Header` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTPHeader` name.
    ///   - value: The `HTTPHeader value.
    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter header: The `HTTPHeader` to update or append.
    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTPHeader` name.
    ///   - value: The `HTTPHeader value.
    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter header: The `HTTPHeader` to update or append.
    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTPHeader` to remove.
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }

        headers.remove(at: index)
    }

    /// Sort the current instance by header name.
    mutating public func sort() {
        headers.sort { $0.name < $1.name }
    }

    /// Returns an instance sorted by header name.
    ///
    /// - Returns: A copy of the current instance sorted by name.
    public func sorted() -> HTTPHeaders {
        HTTPHeaders(headers.sorted { $0.name < $1.name })
    }

    /// Case-insensitively find a header's value by name.
    ///
    /// - Parameter name: The name of the header to search for, case-insensitively.
    ///
    /// - Returns: The value of header, if it exists.
    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }

        return headers[index].value
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()

        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        headers
            .map { $0.description }
            .joined(separator: "\n")
    }
}

// MARK: - HTTPHeader

/// Defines a namespace for common HTTP header fields and values.
public struct HTTPHeader {
    /// Name of the header.
    public let name: String

    /// Value of the header.
    public let value: String

    /// Creates an instance from the given `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

extension Array where Element == HTTPHeader {
    /// Case-insensitively finds the index of an `Header` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - Header Convenience

extension HTTPHeader {
    /// Returns an `Accept` header.
    ///
    /// - Parameter value: The `Accept` value.
    ///
    /// - Returns: The header.
    public static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.accept, value: value)
    }

    /// Returns an `Accept-Charset` header.
    ///
    /// - Parameter value: The `Accept-Charset` value.
    ///
    /// - Returns: The header.
    public static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.acceptCharset, value: value)
    }

    /// Returns an `Accept-Encoding` header.
    ///
    /// - Parameter value: The `Accept-Encoding` value.
    ///
    /// - Returns: The header.
    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.acceptEncoding, value: value)
    }

    /// Returns an `Accept-Language` header.
    ///
    /// - Parameter value: The `Accept-Language` value.
    ///
    /// - Returns: The header.
    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.acceptLanguage, value: value)
    }

    /// Returns a `Basic` `Authorization` header using the `username` and `password` provided.
    ///
    /// - Parameters:
    ///   - username: The username of the header.
    ///   - password: The password of the header.
    ///
    /// - Returns: The header.
    public static func authorization(username: String, password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        let value = HTTPHeader.Value.Authorization.basic(credential)

        return authorization(value)
    }

    /// Returns a `Bearer` `Authorization` header using the `bearerToken` provided
    ///
    /// - Parameter bearerToken: The bearer token.
    ///
    /// - Returns: The header.
    public static func authorization(bearerToken: String) -> HTTPHeader {
        let value = HTTPHeader.Value.Authorization.bearer(bearerToken)
        return authorization(value)
    }

    /// Returns an `Authorization` header.
    ///
    /// - Parameter value: The `Authorization` value.
    ///
    /// - Returns: The header.
    public static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.authorization, value: value)
    }

    /// Returns a `Content-Disposition` header.
    ///
    /// - Parameter value: The `Content-Disposition` value.
    ///
    /// - Returns: The header.
    public static func contentDisposition(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.contentDisposition, value: value)
    }

    /// Returns a `Content-Type` header.
    ///
    /// - Parameter value: The `Content-Type` value.
    ///
    /// - Returns: The header.
    public static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.contentType, value: value)
    }

    /// Returns a `If-None-Match` header.
    ///
    /// - Parameter eTag: An `ETag` value, which is an identifier for a specific version of a resource.
    ///
    /// - Returns: The header.
    public static func ifNoneMatch(_ eTag: String) -> HTTPHeader {
        HTTPHeader(name: HTTPHeader.Field.ifNoneMatch, value: eTag)
    }
}

// MARK: - Header Fields

extension HTTPHeader {
    /// Defines a namespace for common HTTP header fields.
    public struct Field {
        /// The `Accept` header field defining content types that are acceptable for the response.
        public static let accept = "Accept"

        /// The `Accept-Charset` header field defining character sets that are acceptable for the response.
        public static let acceptCharset = "Accept-Charset"

        /// The `Accept-Encoding` header field defining encoding types that are acceptable for the response.
        public static let acceptEncoding = "Accept-Encoding"

        /// The `Accept-Language` header field defining a language code acceptable for the response, including
        /// which locale variant is preferred.
        public static let acceptLanguage = "Accept-Language"

        /// The `appId` header field used in the Nike platform to identify the client.
        public static let appID = "appId"

        /// The `Authorization` header field defining the authentication credentials for HTTP authentication.
        public static let authorization = "Authorization"

        /// The `Content-Disposition` header field indicates if the content is expected to be displayed inline in the
        /// browser or downloaded as an attachment. It can also be used in a multipart body to give information about
        /// the field it applies to.
        public static let contentDisposition = "Content-Disposition"

        /// The `Content-Type` header field defining the MIME type of the request body (used in POST and PUT requests).
        public static let contentType = "Content-Type"

        /// The `ETag` header field that defines an identifier for a specific version of a resource.
        /// See [RFC 7232 - Section 2.3](https://datatracker.ietf.org/doc/html/rfc7232#section-2.3) for more information.
        public static let eTag = "ETag"

        /// The `Expires` header field contains the date/time after which the response is considered stale.
        /// See [RFC 7234 - Section 5.3](https://httpwg.org/specs/rfc7234.html#header.expires) for more information.
        public static let expires = "Expires"

        /// The `"If-None-Match"` header field defining the `ETag` of a previous response for the same resource.
        /// See [RFC 7232 - Section 3.2](https://datatracker.ietf.org/doc/html/rfc7232#section-3.2) for more information.
        public static let ifNoneMatch = "If-None-Match"

        /// The `"x-nike-payment-id"` header field defining the payment ID in the response.
        public static let paymentID = "x-nike-payment-id"

        /// The sensor data header used for bot mitigation at the Akamai layer for certain requests.
        public static let sensorData = "X-acf-sensor-data"

        /// The `Retry-After` header field defining the time period
        public static let retryAfter = "Retry-After"

        /// The `X-B3-TraceId` header field defining the overall trace of the request.
        public static let traceID = "X-B3-TraceId"

        /// The `User-Agent` header field used to identifiy the agent making the request.
        public static let userAgent = "User-Agent"

        /// The `Www-Authenticate` header field indicating the authentication scheme that should be used.
        public static let wwwAuthenticate = "Www-Authenticate"
    }
}

// MARK: - Header Values

extension HTTPHeader {
    /// Defines a namespace for common HTTP header values.
    public struct Value {
        /// Defines a namespace for common HTTP authorization header values.
        public struct Authorization {
            /// Returns an `Authorization` HTTP header value containing the basic auth token.
            ///
            /// - Parameter token: The token to use in the header value.
            ///
            /// - Returns: The `Authorization` header value.
            public static func basic(_ token: String) -> String { "Basic \(token)" }

            /// Returns an `Authorization` HTTP header value containing the bearer auth token.
            ///
            /// - Parameter token: The token to use in the header value.
            ///
            /// - Returns: The `Authorization` header value.
            public static func bearer(_ token: String) -> String { "Bearer \(token)" }
        }

        /// Defines a namespace for the common HTTP `Content-Type` header values.
        public struct ContentType {
            /// The `application/json` HTTP header value for a `Content-Type` HTTP header field.
            public static let applicationJSON = "application/json"

            /// The `application/json; charset=utf-8` HTTP header value for a `Content-Type` HTTP header field.
            public static let applicationJSONCharsetUTF8 = "application/json; charset=utf-8"

            /// The 'application/x-www-form-urlencoded' HTTP header value for a `Content-Type` HTTP header field.
            public static let urlEncoded = "application/x-www-form-urlencoded"
        }

        /// Defines a namespace for the common HTTP `Accept-Charset` header values.
        public struct Charset {
            /// The `utf-8` HTTP header value for a `Accept-Charset` HTTP header field.
            public static let utf8 = "utf-8"
        }
    }
}

// MARK: - System Type Extensions

extension URLRequest {
    /// Returns `allHTTPHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        get { allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.dictionary }
    }
}

extension HTTPURLResponse {
    /// Returns `allHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}

extension URLSessionConfiguration {
    /// Returns `httpAdditionalHeaders` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        get { (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { httpAdditionalHeaders = newValue.dictionary }
    }
}
