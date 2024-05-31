//
//  TaskMetrics.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/19/22.
//  Copyright © 2022 Nike. All rights reserved.
//

import Foundation

/// An object encapsulating the metrics for a session task.
///
/// Each `TaskMetrics` object contains the `taskInterval` and `redirectCount`, as well as metrics for each
/// request-and-response transaction made during the execution of the task.
///
/// This object is simply a wrapper around `URLSessionTaskMetrics` that exists as a workaround for Apple deprecating
/// the initializer. We plan to file radars around this limitation in an attempt to get Apple to change course here.
/// These initializers "should" continue to be made available for testing purposes.
public struct TaskMetrics {
    /// An array of metrics for each individual request-response transaction made during the execution of the task.
    public let transactionMetrics: [TaskTransactionMetrics]

    /// The time interval between when a task is instantiated and when the task is completed.
    public let taskInterval: DateInterval

    /// The number of redirects that occurred during the execution of the task.
    public let redirectCount: Int

    /// Creates a task metrics instance.
    ///
    /// - Parameters:
    ///   - transactionMetrics: The transaction metrics.
    ///   - taskInterval: The task interval.
    ///   - redirectCount: The redirect count.
    public init(transactionMetrics: [TaskTransactionMetrics], taskInterval: DateInterval, redirectCount: Int) {
        self.transactionMetrics = transactionMetrics
        self.taskInterval = taskInterval
        self.redirectCount = redirectCount
    }

    /// Creates a `TaskMetrics` instance from the specified `URLSessionTaskMetrics` instance.
    ///
    /// - Parameter metrics: The metrics.
    public init(metrics: URLSessionTaskMetrics) {
        self.transactionMetrics = metrics.transactionMetrics.map { TaskTransactionMetrics(metrics: $0) }
        self.taskInterval = metrics.taskInterval
        self.redirectCount = metrics.redirectCount
    }
}
