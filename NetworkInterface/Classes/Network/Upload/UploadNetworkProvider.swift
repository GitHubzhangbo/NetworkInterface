//
//  UploadNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/5/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that executes network requests by uploading the data to the server, then processing the response using a
/// single value response serializer.
public protocol UploadNetworkProvider {
    /// Tuple type representing the upload progress updates flowing to the closure on the queue.
    typealias UploadProgress = (queue: DispatchQueue, closure: (Progress) -> Void)

    /// Executes a network request which uploads the uploadable data to the server, then retrieves the response from
    /// the server and serializes it to the generic value type.
    ///
    /// - Parameters:
    ///   - uploadable:         The uploadable.
    ///   - options:            The request options.
    ///   - progress:           The upload progress.`
    ///   - responseSerializer: The response serializer used to serialize the response data.
    ///   - completion:         The closure called once the request is complete.
    ///
    /// - Returns: The upload task.
    @discardableResult
    func uploadTask<ValueResponseSerializer>(
        from uploadable: Uploadable,
        options: RequestOptions,
        progress: UploadProgress?,
        responseSerializer: ValueResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject, RequestError>) -> Void)
        -> UploadTask where
            ValueResponseSerializer: ResponseSerializer
}

// MARK: -

extension UploadNetworkProvider {
    /// Executes a network request that uploads the data from the file to the server, then retrieves the response from
    /// the server and serializes it to the decodable value type.
    ///
    /// - Parameters:
    ///   - request:    The request.
    ///   - fileURL:    The url of the file to upload.
    ///   - options:    The request options. `RequestOptions()` by default.
    ///   - progress:   The upload progress. `nil` by default.
    ///   - valueType:  The decodable value type. `Value.self` by default.
    ///   - decoder:    The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion: The closure called once the request is complete.
    ///
    /// - Returns: The upload task.
    @discardableResult
    public func uploadTaskForDecodable<Value>(
        with request: Request,
        fileURL: URL,
        options: RequestOptions = RequestOptions(),
        progress: UploadProgress? = nil,
        valueType: Value.Type = Value.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<Value, RequestError>) -> Void)
        -> UploadTask where
            Value: Decodable
    {
        let responseSerializer = DecodableResponseSerializer<Value>(decoder: decoder)

        return uploadTask(
            from: .file(request, fileURL),
            options: options,
            progress: progress,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    /// Executes a network request that uploads the data from the input stream to the server, then retrieves the
    /// response from the server and serializes it to the decodable value type.
    ///
    /// - Parameters:
    ///   - request:     The request.
    ///   - inputStream: The input stream of data to upload.
    ///   - options:     The request options. `RequestOptions()` by default.
    ///   - progress:    The upload progress. `nil` by default.
    ///   - valueType:   The decodable value type. `Value.self` by default.
    ///   - decoder:     The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion:  The closure called once the request is complete.
    ///
    /// - Returns: The upload task.
    @discardableResult
    public func uploadTaskForDecodable<Value>(
        with request: Request,
        inputStream: InputStream,
        options: RequestOptions = RequestOptions(),
        progress: UploadProgress? = nil,
        valueType: Value.Type = Value.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<Value, RequestError>) -> Void)
        -> UploadTask where
            Value: Decodable
    {
        let responseSerializer = DecodableResponseSerializer<Value>(decoder: decoder)

        return uploadTask(
            from: .stream(request, inputStream),
            options: options,
            progress: progress,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }
}

// MARK: -

/// Type describing the source used to create the upload task.
public enum Uploadable {
    /// Upload the data from the file url.
    case file(Request, URL)

    /// Upload the data from the input stream.
    case stream(Request, InputStream)
}

// MARK: -

/// A type that controls the execution of an upload request.
public protocol UploadTask: Task {}
