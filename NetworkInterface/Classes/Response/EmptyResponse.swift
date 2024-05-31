//
//  EmptyResponse.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/27/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A protocol for a type representing an empty response. Use `T.emptyValue` to get an instance.
public protocol EmptyResponse {
    /// Empty value for the conforming type.
    ///
    /// - Returns: The value of `Self` to use for empty values.
    static func emptyValue() -> Self
}

/// A type representing an empty response. Use `Empty.value` to get the instance.
public struct Empty: Decodable, EmptyResponse {
    public static func emptyValue() -> Empty { Empty() }
}
