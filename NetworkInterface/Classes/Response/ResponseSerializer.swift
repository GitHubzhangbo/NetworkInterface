//
//  ResponseSerializer.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/21/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A type used to serialize a response from a server.
public protocol ResponseSerializer {
    /// The type of serialized object to be created by the serializer.
    associatedtype SerializedObject

    /// Serializes the response data into the serialized object type.
    ///
    /// - Parameters:
    ///   - request:  The original request.
    ///   - response: The response from the server.
    ///   - data:     The data receiver from the server.
    ///   - error:    The error that occurred during the request lifecycle.
    ///
    /// - Returns: The serialized object.
    ///
    /// - Throws: Any `Error` type thrown during serialization.
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> SerializedObject
}

// MARK: - Decodable

/// A response serializer that decodes json response data as a generic value using any type that conforms to `Decodable`.
public struct DecodableResponseSerializer<T: Decodable>: NetworkInterface.ResponseSerializer {
    public typealias SerializedObject = T

    /// The json decoder used to serialize the response data.
    public let decoder: JSONDecoder

    /// Creates a `DecodableResponseSerializer` type from the specified `decoder`.
    ///
    /// - Parameter decoder: The decoder to use to serialize the response data.
    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else { throw error! }

        guard let data = data, !data.isEmpty else {
            guard
                let emptyResponseType = T.self as? NetworkInterface.EmptyResponse.Type,
                let emptyValue = emptyResponseType.emptyValue() as? T
            else {
                throw NetworkInterface.RequestError.serialization(
                    .serializationFailed(description: "invalid empty response type: \(T.self)", error: nil)
                )
            }

            return emptyValue
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkInterface.RequestError.serialization(.decodingFailed(decodingError))
        } catch {
            throw NetworkInterface.RequestError.serialization(.serializationFailed(description: "\(error)", error: nil))
        }
    }
}

// MARK: - String

/// A response serializer that decodes the response data as a `String`.
public struct StringResponseSerializer: ResponseSerializer {
    /// The string encoding to use when decoding the response data.
    public let encoding: String.Encoding

    /// Creates a `StringResponseSerializer` instance from the specified `encoding`.
    ///
    /// - Parameter encoding: The string encoding to use to decode the response data.
    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> String {
        guard error == nil else { throw error! }

        guard let data = data, !data.isEmpty else {
            throw NetworkInterface.RequestError.serialization(
                .serializationFailed(description: "invalid empty response data", error: nil)
            )
        }

        guard
            let string = String(data: data, encoding: encoding)
        else {
            throw NetworkInterface.RequestError.serialization(
                .serializationFailed(description: "failed to convert data to String with encoding: \(encoding)", error: nil)
            )
        }

        return string
    }
}
