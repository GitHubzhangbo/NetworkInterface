//
//  Task.swift
//  NetworkInterface
//
//  Created by Christian Noon on 2/23/20.
//  Copyright © 2020 Nike. All rights reserved.
//

import Foundation

/// A type that can be converted into a `cURL` command that can be used in the terminal.
public protocol cURLCommandConvertible {
    /// Converts the type into a cURL command when available and provides it to the `handler`.
    ///
    /// - Parameter handler: The closure executed once the cURL command is generated.
    func cURL(calling handler: @escaping (String) -> Void)
}

// MARK: -

/// A type that controls the execution of a request. All `Task` types are automatically "resumed" when created.
/// There is no need to call `resume` initially, only after a task has been `suspended`.
public protocol Task: cURLCommandConvertible {
    /// Resumes the request, if suspended.
    func resume()

    /// Temporarily suspends the request.
    func suspend()

    /// Cancels the request.
    func cancel()
}
