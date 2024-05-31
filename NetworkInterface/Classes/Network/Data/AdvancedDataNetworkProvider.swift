//
//  AdvancedDataNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/7/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

/// A type that executes advanced network requests using both a value response serializer and error response serializer.
/// This more complex provider vends `Result` instances with `ServiceError` error types to account for `ServiceFailure`
/// errors embedded in the response data from the server.
public protocol AdvancedDataNetworkProvider {
    /// Executes the request to retrieve the server response data and serialize it to the generic value or error type.
    ///
    /// - Note: This API should only be used when errors are embedded within the payload itself. If this is not the
    ///         case, then the `DataNetworkProvider` APIs should be sufficient.
    ///
    /// - Parameters:
    ///   - request:                 The request.
    ///   - options:                 The request options.
    ///   - responseSerializer:      The response serializer used to serialize the response data to the value type.
    ///   - responseErrorSerializer: The response serializer used to serialize the response data to the error type.
    ///   - completion:              The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    func dataTask<ValueResponseSerializer, ErrorResponseSerializer>(
        with request: Request,
        options: RequestOptions,
        responseSerializer: ValueResponseSerializer,
        responseErrorSerializer: ErrorResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject, ServiceError<ErrorResponseSerializer.SerializedObject>>) -> Void)
        -> DataTask where
            ValueResponseSerializer: ResponseSerializer,
            ErrorResponseSerializer: ResponseSerializer,
            ErrorResponseSerializer.SerializedObject: ServiceFailure
}

// MARK: -

extension AdvancedDataNetworkProvider {
    /// Executes the request to retrieve the server response data and serialize it to the decodable success or failure type.
    ///
    /// - Note: This API should only be used when errors are embedded within the payload itself. If this is not the
    ///         case, then the `DataNetworkProvider` APIs should be sufficient.
    ///
    /// - Parameters:
    ///   - request:    The request.
    ///   - options:    The request options.
    ///   - valueType:  The decodable value type. `Value.self` by default.
    ///   - errorType:  The decodable error type that must conform to `ServiceFailure`. `Error.self` by default.
    ///   - decoder:    The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion: The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    public func dataTaskForAdvancedDecodable<Value, Error>(
        with request: Request,
        options: RequestOptions = RequestOptions(),
        valueType: Value.Type = Value.self,
        errorType: Error.Type = Error.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<Value, ServiceError<Error>>) -> Void)
        -> DataTask where
            Value: Decodable,
            Error: Decodable & ServiceFailure
    {
        let responseSerializer = DecodableResponseSerializer<Value>(decoder: decoder)
        let responseErrorSerializer = DecodableResponseSerializer<Error>(decoder: decoder)

        return dataTask(
            with: request,
            options: options,
            responseSerializer: responseSerializer,
            responseErrorSerializer: responseErrorSerializer,
            completion: completion
        )
    }
}

// swiftlint:enable line_length
