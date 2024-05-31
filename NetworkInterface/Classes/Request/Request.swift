//
//  Request.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/21/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Types adopting the `Request` protocol can be used to safely construct `URLRequest`s.
public protocol Request {
    /// Returns a `URLRequest` or throws if an `Error` was encoutered.
    ///
    /// - Returns: A `URLRequest`.
    /// - Throws:  Any error thrown while constructing the `URLRequest`.
    func asURLRequest() throws -> URLRequest
}

extension URL: Request {
    public func asURLRequest() throws -> URLRequest {
        URLRequest(url: self)
    }
}

extension URLRequest: Request {
    public func asURLRequest() throws -> URLRequest {
        self
    }
}
