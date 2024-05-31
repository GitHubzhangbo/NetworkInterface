//
//  HTTPBody.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Represents an http body of data along with the content type of the data.
public protocol HTTPBody {
    /// The body data.
    var data: Data { get }

    /// The content type of the body data (i.e. "application/json").
    var contentType: String { get }
}

// MARK: -

/// An immutable model object representing an encoded http body.
public struct EncodedBody: HTTPBody {
    public let data: Data
    public let contentType: String

    /// Creates an `EncodedBody` instance with the specified `data` and `contentType`.
    ///
    /// - Parameters:
    ///   - data:        The body data.
    ///   - contentType: The content type of the body data.
    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}
