//
//  HTTPMethod.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// HTTP method definitions.
///
/// See [RFC-7231, Section 4.3](https://tools.ietf.org/html/rfc7231#section-4.3) for more information.
public struct HTTPMethod: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Cases

extension HTTPMethod {
    /// The `CONNECT` method.
    public static let connect = HTTPMethod(rawValue: "CONNECT")

    /// The `DELETE` method.
    public static let delete = HTTPMethod(rawValue: "DELETE")

    /// The `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")

    /// The `HEAD` method.
    public static let head = HTTPMethod(rawValue: "HEAD")

    /// The `OPTIONS` method.
    public static let options = HTTPMethod(rawValue: "OPTIONS")

    /// The `PATCH` method.
    public static let patch = HTTPMethod(rawValue: "PATCH")

    /// The `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")

    /// The `PUT` method.
    public static let put = HTTPMethod(rawValue: "PUT")

    /// The `TRACE` method.
    public static let trace = HTTPMethod(rawValue: "TRACE")
}

// MARK: CaseIterable

extension HTTPMethod: CaseIterable {
    public static var allCases: Set<HTTPMethod> {
        [
            .connect,
            .delete,
            .get,
            .head,
            .options,
            .patch,
            .post,
            .put,
            .trace
        ]
    }
}

// MARK: - System Type Extensions

extension URLRequest {
    /// The http request method.
    public var method: HTTPMethod {
        get {
            guard let httpMethod = httpMethod else { return .get }
            return HTTPMethod(rawValue: httpMethod)
        }
        set {
            httpMethod = newValue.rawValue
        }
    }
}
