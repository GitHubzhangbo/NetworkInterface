//
//  DownloadNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/3/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that executes network requests by downloading the data to a temporary file, then moving the temporary file
/// to the destination url.
public protocol DownloadNetworkProvider {
    /// Tuple type representing the download progress updates flowing to the closure on the queue.
    typealias DownloadProgress = (queue: DispatchQueue, closure: (Progress) -> Void)

    /// Executes the request to retrieve server response data by downloading it to a temporary file and moving it to
    /// the destination url.
    /// - Parameters:
    ///   - downloadable: The downloadable.
    ///   - options:      The request options.
    ///   - progress:     The download progress. `nil` by default.
    ///   - destination:  The download destination.
    ///   - completion:   The closure called once the request is complete.
    ///
    /// - Returns: The download task.
    @discardableResult
    func downloadTask(
        from downloadable: Downloadable,
        options: RequestOptions,
        progress: DownloadProgress?,
        destination: DownloadDestination,
        completion: @escaping (Response<URL, RequestError>) -> Void)
        -> DownloadTask
}

// MARK: -

extension DownloadNetworkProvider {
    /// Executes the request to retrieve the server response data by downloading to a temporary file and moving it to
    /// the destination url.
    ///
    /// - Parameters:
    ///   - request:     The request.
    ///   - options:     The request options. `RequestOptions()` by default.
    ///   - progress:    The download progress. `nil` by default.
    ///   - destination: The download destination.
    ///   - completion:  The closure called once the request is complete.
    ///
    /// - Returns: The download task.
    @discardableResult
    public func downloadTask(
        with request: Request,
        options: RequestOptions = RequestOptions(),
        progress: DownloadProgress? = nil,
        destination: DownloadDestination,
        completion: @escaping (Response<URL, RequestError>) -> Void)
        -> DownloadTask
    {
        downloadTask(
            from: .request(request),
            options: options,
            progress: progress,
            destination: destination,
            completion: completion
        )
    }

    /// Executes the url request embedded within the resume data by resuming the download where it left off and moving
    /// the temporary file to the destination url once complete.
    ///
    /// - Note: This resume data API should not be used when `Authentication` is not `nil` in `RequestOptions`. Apple
    ///         does not allow any `URLRequest` customization when leveraging resume data. Instead, use the `Request`
    ///         API can set the `Range` headers manually.
    ///
    /// - Parameters:
    ///   - resumeData:  The resume data produced by cancelling a previous request.
    ///   - options:     The request options. `RequestOptions()` by default.
    ///   - progress:    The download progress. `nil` by default.
    ///   - destination: The download destination.
    ///   - completion:  The closure called once the request is complete.
    ///
    /// - Returns: The download task.
    @discardableResult
    public func downloadTask(
        from resumeData: Data,
        options: RequestOptions = RequestOptions(),
        progress: DownloadProgress? = nil,
        destination: DownloadDestination,
        completion: @escaping (Response<URL, RequestError>) -> Void)
        -> DownloadTask
    {
        downloadTask(
            from: .resumeData(resumeData),
            options: options,
            progress: progress,
            destination: destination,
            completion: completion
        )
    }
}

// MARK: -

/// Type describing the source used to create the download task.
public enum Downloadable {
    /// Download should be started from the `Request`.
    case request(Request)

    /// Download should be generated from the associated resume data.
    case resumeData(Data)
}

// MARK: -

/// The `DownloadDestination` struct is a container type that stores where to move the temporary file to after it has
/// finished downloading. It also has the ability to set up and clean up the file system as part of the process.
public struct DownloadDestination {
    /// A closure executed once a download request has successfully completed in order to determine where to move the
    /// temporary file written during the download process.
    public let destinationURL: (_ temporaryURL: URL, _ response: HTTPURLResponse) -> URL

    /// Whether intermediate directories for the destination url should be created.
    public let createIntermediateDirectories: Bool

    /// Whether any previous file at the destination url should be removed.
    public let removePreviousFile: Bool

    /// Creates a `DownloadDestination` instance from the specified parameters.
    /// - Parameters:
    ///   - destinationURL:                The destination url.
    ///   - createIntermediateDirectories: Whether to create intermediate directories. `false` by default.
    ///   - removePreviousFile:            Whether to remove previous file. `false` by default.
    ///
    /// - Returns: The new instance.
    public init(
        destinationURL: @escaping (_ temporaryURL: URL, _ response: HTTPURLResponse) -> URL,
        createIntermediateDirectories: Bool = false,
        removePreviousFile: Bool = false)
    {
        self.destinationURL = destinationURL
        self.createIntermediateDirectories = createIntermediateDirectories
        self.removePreviousFile = removePreviousFile
    }
}

// MARK: -

/// A type that controls the execution of a download request.
public protocol DownloadTask: Task {
    /// Cancels the request and attempts to produce resume data to resume the request in the future.
    func cancel(byProducingResumeData completion: @escaping (Data?) -> Void)
}
