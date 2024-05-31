//
//  DataNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/7/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that executes data network requests using a single value response serializer.
public protocol DataNetworkProvider {
    /// Executes the request to retrieve the server response data and serialize it to the generic value type.
    ///
    /// - Parameters:
    ///   - request:            The request.
    ///   - options:            The request options.
    ///   - responseSerializer: The response serializer used to serialize the response data.
    ///   - completion:         The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    func dataTask<ValueResponseSerializer>(
        with request: Request,
        options: RequestOptions,
        responseSerializer: ValueResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject, RequestError>) -> Void)
        -> DataTask where
            ValueResponseSerializer: ResponseSerializer
}

// MARK: -

extension DataNetworkProvider {
    /// Executes the request to retrieve the server response data and serialize it to the decodable value type.
    ///
    /// - Parameters:
    ///   - request:    The request.
    ///   - options:    The request options.
    ///   - valueType:  The decodable value type. `Value.self` by default.
    ///   - decoder:    The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion: The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    public func dataTaskForDecodable<Value>(
        with request: Request,
        options: RequestOptions = RequestOptions(),
        valueType: Value.Type = Value.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<Value, RequestError>) -> Void)
        -> DataTask where
            Value: Decodable
    {
        let responseSerializer = DecodableResponseSerializer<Value>(decoder: decoder)

        return dataTask(
            with: request,
            options: options,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }
}

// MARK: -

/// A type that controls the execution of a data request.
public protocol DataTask: Task {}
