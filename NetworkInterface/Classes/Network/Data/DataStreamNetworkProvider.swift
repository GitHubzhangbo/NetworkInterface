//
//  DataStreamNetworkProvider.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/3/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that executes network requests and stream the data back through the data stream closure.
public protocol DataStreamNetworkProvider {
    /// Tuple type representing the stream of data flowing to the closure on the queue.
    typealias DataStream = (queue: DispatchQueue, closure: (Progress, Data) throws -> Void)

    /// Executes the request to retrieve the server response data and stream it to the data stream closure.
    ///
    /// - Parameters:
    ///   - request:    The request.
    ///   - options:    The request options.
    ///   - stream:     The data stream to stream the data to.
    ///   - completion: The closure called once the request is complete.
    ///
    /// - Returns: The data stream task.
    @discardableResult
    func dataStreamTask(
        with request: Request,
        options: RequestOptions,
        stream: DataStream,
        completion: @escaping (Response<Void, RequestError>) -> Void)
        -> DataStreamTask
}

// MARK: -

/// A type that controls the execution of a data stream request.
public protocol DataStreamTask: Task {}
