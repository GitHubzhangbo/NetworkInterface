//
//  RedirectPolicy.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Defines the redirect policy for a request.
public enum RedirectPolicy {
    /// Follows the redirect as defined in the response.
    case follow

    /// Does not follow the redirect defined in the response.
    case doNotFollow

    /// Modifies the redirect request defined in the response.
    case modify((URLSessionTask, URLRequest, HTTPURLResponse) -> URLRequest?)
}
