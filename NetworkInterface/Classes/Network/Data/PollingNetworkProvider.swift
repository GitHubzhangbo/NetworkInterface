//
//  PollingNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/3/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

/// A type that executes basic network requests using a single value response serializer that is also `Pollable`. This
/// supports use cases where the polling behavior is built into the actual json payload rather than the url response.
/// In cases like 429 status codes, generally retry policies are a better approach to polling.
public protocol PollingNetworkProvider {
    /// Executes the request to retrieve and serialize the server response data and polls as directed by the payload.
    ///
    /// - Parameters:
    ///   - request:            The request.
    ///   - retryLimit:         The maximum number of times to poll.
    ///   - options:            The request options.
    ///   - responseSerializer: The response serializer used to serialize the response data.
    ///   - completion:         The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    func pollingDataTask<ValueResponseSerializer>(
        with request: Request,
        retryLimit: UInt?,
        options: RequestOptions,
        responseSerializer: ValueResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject.Success, ServiceError<ValueResponseSerializer.SerializedObject.Failure>>) -> Void)
        -> DataTask where
            ValueResponseSerializer: ResponseSerializer,
            ValueResponseSerializer.SerializedObject: Pollable
}

// MARK: -

extension PollingNetworkProvider {
    /// Executes the request to retrieve and serialize the server response data and polls as directed by the payload.
    ///
    /// - Parameters:
    ///   - request:            The request.
    ///   - options:            The request options.
    ///   - responseSerializer: The response serializer used to serialize the response data.
    ///   - completion:         The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @available(*, deprecated, message: "Use the version of pollingDataTask that takes the optional retryLimit parameter as declared in PollingNetworkProvider")
    @discardableResult
    func pollingDataTask<ValueResponseSerializer>(
        with request: Request,
        options: RequestOptions,
        responseSerializer: ValueResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject.Success, ServiceError<ValueResponseSerializer.SerializedObject.Failure>>) -> Void)
        -> DataTask where
            ValueResponseSerializer: ResponseSerializer,
            ValueResponseSerializer.SerializedObject: Pollable
    {
        pollingDataTask(with: request, retryLimit: nil, options: options, responseSerializer: responseSerializer, completion: completion)
    }

    /// Executes the request to retrieve and serialize the server response data and polls as directed by the payload.
    ///
    /// - Parameters:
    ///   - request:         The request.
    ///   - retryLimit:      The maximum number of times to poll. `nil` by default.
    ///   - options:         The request options.
    ///   - pollableType:    The decodable, pollable value type. `PollableType.self` by default.
    ///   - decoder:         The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion:      The closure called once the request is complete.
    ///
    /// - Returns: The data task.
    @discardableResult
    public func pollingDataTaskForDecodable<PollableType>(
        with request: Request,
        retryLimit: UInt? = nil,
        options: RequestOptions = RequestOptions(),
        pollableType: PollableType.Type = PollableType.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<PollableType.Success, ServiceError<PollableType.Failure>>) -> Void)
        -> DataTask where
            PollableType: Decodable & Pollable
    {
        let responseSerializer = DecodableResponseSerializer<PollableType>(decoder: decoder)

        return pollingDataTask(
            with: request,
            retryLimit: retryLimit,
            options: options,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }
}

// swiftlint:enable line_length

// MARK: -

/// A type that supports polling through the `PollResult` type.
public protocol Pollable {
    /// The type of object being polled.
    associatedtype Success

    /// The error type of object being polled.
    associatedtype Failure: ServiceFailure

    /// The result of a polling operation to retrieve its `Value`.
    var pollResult: PollResult<Success, Failure> { get }
}

// MARK: -

/// A result type used to represent whether a polling operation was successful, encountered an error, or is still in
/// progress.
public enum PollResult<Success, Failure: ServiceFailure> {
    /// The polling operation was successful resulting in the serialization of the provided associated value.
    case success(value: Success)

    /// The polling operation failed when encountering an error provided as the associated value.
    case failure(error: Failure)

    /// The polling operation is still in progress leveraging the provided polling info to continue.
    case inProgress(info: PollingInfo)
}

// MARK: -

/// An immutable model object containing the polling information about an upcoming poll operation containing the
/// time interval to delay.
public struct PollingInfo {
    /// The time interval to delay until beginning the poll operation.
    public let eta: TimeInterval

    /// Creates a `PollingInfo` instance from the specified `eta` and `resource`.
    ///
    /// - Parameter eta: The time interval to delay until beginning the poll operation.
    public init(eta: TimeInterval) {
        self.eta = eta
    }
}
