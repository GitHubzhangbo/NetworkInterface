//
//  RetryResult.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Represents all possible retry options.
public enum RetryResult {
    /// Retry should be attempted immediately.
    case retry

    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)

    /// Do not retry.
    case doNotRetry

    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(Error)
}
