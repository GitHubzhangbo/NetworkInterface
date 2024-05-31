//
//  Authenticator.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/29/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that authenticates url requests for the supported authentication.
public protocol Authenticator {
    /// The supported authentication.
    var authentication: Authentication { get }

    /// Authenticates the url request and calls the completion closure with a result type when finished.
    ///
    /// - Parameters:
    ///   - urlRequest: The url request to authenticate.
    ///   - completion: The completion closure that must be called when authentication is complete.
    func authenticate(_ urlRequest: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void)
}
