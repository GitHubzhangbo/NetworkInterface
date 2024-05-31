//
//  MultipartFormDataNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/5/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that executes network requests by uploading multipart form data to the server, then processing the response
/// using a single value response serializer.
public protocol MultipartFormDataNetworkProvider {
    /// Tuple type representing the upload progress updates flowing to the closure on the queue.
    typealias UploadProgress = (queue: DispatchQueue, closure: (Progress) -> Void)

    /// Executes a network request which uploads the multipart form data to the server, then retrieves the response
    /// from the server and serializes it to the generic value type.
    ///
    /// - Parameters:
    ///   - request:                 The request.
    ///   - options:                 The request options.
    ///   - encodingMemoryThreshold: The byte threshold used to determine whether the form data is encoded into memory
    ///                              or onto disk before being uploaded.
    ///   - progress:                The upload progress.
    ///   - responseSerializer:      The response serializer used to serialize the response.
    ///   - completion:              The closure called once the request is complete.
    ///
    /// - Returns: The multipart form data task.
    @discardableResult
    func multipartFormDataTask<ValueResponseSerializer>(
        with request: MultipartFormDataRequest,
        options: RequestOptions,
        encodingMemoryThreshold: UInt64,
        progress: UploadProgress?,
        responseSerializer: ValueResponseSerializer,
        completion: @escaping (Response<ValueResponseSerializer.SerializedObject, RequestError>) -> Void)
        -> MultipartFormDataTask where
            ValueResponseSerializer: ResponseSerializer
}

// MARK: -

extension MultipartFormDataNetworkProvider {
    /// Executes a network request which uploads the multipart form data to the server, then retrieves the response
    /// from the server and serializes it to the decodable value type.
    ///
    /// - Parameters:
    ///   - request:                 The request.
    ///   - options:                 The request options.
    ///   - encodingMemoryThreshold: The byte threshold used to determine whether the form data is encoded into memory
    ///                              or onto disk before being uploaded. `10_000_000` by default.
    ///   - progress:                The upload progress. `nil` by default.
    ///   - valueType:               The decodable value type. `Value.self` by default.
    ///   - decoder:                 The json decoder to use during serialization. `JSONDecoder()` by default.
    ///   - completion:              The closure called once the request is complete.
    ///
    /// - Returns: The multipart form data task.
    @discardableResult
    public func multipartFormDataTaskForDecodable<Value>(
        with request: MultipartFormDataRequest,
        options: RequestOptions = RequestOptions(),
        encodingMemoryThreshold: UInt64 = 10_000_000,
        progress: UploadProgress? = nil,
        valueType: Value.Type = Value.self,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Response<Value, RequestError>) -> Void)
        -> MultipartFormDataTask where
            Value: Decodable
    {
        let responseSerializer = DecodableResponseSerializer<Value>(decoder: decoder)

        return multipartFormDataTask(
            with: request,
            options: options,
            encodingMemoryThreshold: encodingMemoryThreshold,
            progress: progress,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }
}

// MARK: -

/// Types adopting the `MultipartFormDataRequest` protocol can be used to safely construct `URLRequest`s.
public protocol MultipartFormDataRequest {
    /// The HTTP method definitions. See [RFC 7231](http://tinyurl.com/hdbkd3q) for more info.
    var method: HTTPMethod { get }

    /// The base url string of the url (i.e. "https://api.nike.com").
    var baseURLString: String { get }

    /// Returns the relative path of the url.
    ///
    /// - Returns: The relative path of the url.
    /// - Throws: A `RequestError.initialization` when creating the path encounters an unrecoverable failure.
    func path() throws -> String

    /// Returns the query parameters to append to the url.
    ///
    /// - Returns: The query parameters to append to the url.
    /// - Throws: A `RequestError.initialization` if creating the query parameters encounters an unrecoverable failure.
    func queryParameters() throws -> QueryParameters

    /// Returns the http headers to append to the url request.
    ///
    /// - Returns: The http headers to append to the url request.
    /// - Throws: A `RequestError.initialization` if creating the headers encounters an unrecoverable failure.
    func headers() throws -> HTTPHeaders

    /// Provides the multipart form data object to append body chunks to.
    ///
    /// - Parameter multipartFormData: The multipart form data.
    /// - Throws: A `RequestError.initialization` if creating the body encounters an unrecoverable failure.
    func multipartFormData(_ multipartFormData: MultipartFormData) throws

    /// Allows the urlRequest parameters to be modified before being sent to any adapters prior to execution.
    ///
    /// The request modifier is meant to give clients direct access to the underlying `URLRequest` immediately after
    /// being created, before it is sent off to the adapters. It is only meant to be a single use operation for the
    /// `DeferredRequest` it is attached to. It is not an async API, and is only intended to be used
    /// to set any remaining `URLRequest` APIs that are not directly exposed through the `DeferredRequest` protocol
    /// such as `timeoutInterval`, `cachePolicy`, `allowsCellularAccess`, etc. It should not be used to modify things
    /// that already exist in the `DeferredRequest` protocol like `httpMethod`,
    /// `httpBody`, etc.
    ///
    /// Another important note is that a request modifier IS NOT an interceptor, and should not be used as one. If you
    /// need to use custom interceptors to support custom authentication, or nested adapters, then you should use
    /// the `interceptors` property on `RequestOptions`.
    ///
    /// - Parameter urlRequest: The url request to be modified.
    /// - Throws: A `RequestError.initialization` if modifying the `URLRequest` encounters an unrecoverable failure.
    func requestModifier(_ urlRequest: inout URLRequest) throws
}

// MARK: -

extension MultipartFormDataRequest {
    /// Returns the query parameters to append to the url.
    ///
    /// - Returns: The query parameters to append to the url.
    /// - Throws: A `RequestError.initialization` if creating the query parameters encounters an unrecoverable failure.
    public func queryParameters() throws -> QueryParameters {
        [:]
    }

    /// Returns the http headers to append to the url request.
    ///
    /// - Returns: The http headers to append to the url request.
    /// - Throws: A `RequestError.initialization` if creating the headers encounters an unrecoverable failure.
    public func headers() throws -> HTTPHeaders {
        [:]
    }

    /// Allows the urlRequest parameters to be modified before being sent to any adapters prior to execution.
    ///
    /// The request modifier is meant to give clients direct access to the underlying `URLRequest` immediately after
    /// being created, before it is sent off to the adapters. It is only meant to be a single use operation for the
    /// `DeferredRequest` it is attached to. It is not an async API, and is only intended to be used
    /// to set any remaining `URLRequest` APIs that are not directly exposed through the `DeferredRequest` protocol
    /// such as `timeoutInterval`, `cachePolicy`, `allowsCellularAccess`, etc. It should not be used to modify things
    /// that already exist in the `DeferredRequest` protocol like `httpMethod`,
    /// `httpBody`, etc.
    ///
    /// Another important note is that a request modifier IS NOT an interceptor, and should not be used as one. If you
    /// need to use custom interceptors to support custom authentication, or nested adapters, then you should use
    /// the `interceptors` property on `RequestOptions`.
    ///
    /// - Parameter urlRequest: The url request to be modified.
    /// - Throws: A `RequestError.initialization` if modifying the `URLRequest` encounters an unrecoverable failure.
    public func requestModifier(_ urlRequest: inout URLRequest) throws {
        // No-op
    }
}

// MARK: -

/// Represents a type capable of constructing data with a `multipart/form-data` content type.
///
/// For more information on `multipart/form-data`, please refer to the RFC-2388 and RFC-2045 specs as well and the w3
/// form documentation.
///
/// - https://www.ietf.org/rfc/rfc2388.txt
/// - https://www.ietf.org/rfc/rfc2045.txt
/// - https://www.w3.org/TR/html401/interact/forms.html#h-17.13
public protocol MultipartFormData: AnyObject {
    /// Creates a body part from the data and appends it to the builder.
    ///
    /// - Parameters:
    ///   - data:     The data to encode into the body part.
    ///   - name:     The name to associate with the data in the `Content-Disposition` header.
    ///   - fileName: The filename to associate with the data in the `Content-Disposition` header.
    ///   - mimeType: The mime type to associate with the data in the `Content-Type` header.
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?)

    /// Creates a body part from the file and appends it to the builder.
    ///
    /// - Parameters:
    ///   - fileURL: The file url whose content will be encoded into the body part.
    ///   - name:    The name to associate with the file content in the `Content-Disposition` header.
    func append(_ fileURL: URL, withName name: String)

    /// Creates a body part from the file and appends it to the builder.
    ///
    /// - Parameters:
    ///   - fileURL: The file url whose content will be encoded into the body part.
    ///   - name:    The name to associate with the file content in the `Content-Disposition` header.
    ///   - fileName: The filename to associate with the file content in the `Content-Disposition` header.
    ///   - mimeType: The mime type to associate with the file content in the `Content-Type` header.
    func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String)

    /// Creates a body part from the stream and appends it to the builder.
    ///
    /// - Parameters:
    ///   - stream:   The stream whose content will be encoded into the body part.
    ///   - length:   The length, in bytes, of the stream content.
    ///   - name:     The name to associate with the stream content in the `Content-Disposition` header.
    ///   - fileName: The filename to associate with the stream content in the `Content-Disposition` header.
    ///   - mimeType: The mime type to associate with the stream content in the `Content-Type` header.
    func append(_ stream: InputStream, withLength length: UInt64, name: String, fileName: String, mimeType: String)

    /// Creates a body part from the stream and appends it to the builder.
    ///
    /// - Parameters:
    ///   - stream:  The stream whose content will be encoded into the body part.
    ///   - length:  The length, in bytes, of the stream content.
    ///   - headers: The http headers for the body part.
    func append(_ stream: InputStream, withLength length: UInt64, headers: HTTPHeaders)
}

// MARK: -

/// A type that controls the execution of a multipart form data request.
public protocol MultipartFormDataTask: Task {}
