//
//  Authentication.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/18/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Defines an authentication type to apply to a request. These authentication types only support Nike endpoints and
/// should not be used for third party services.
public enum Authentication {
    /// The consumer authentication is intended to be used by all Nike services that support consumer OAuth2
    /// authentication. Adding this authentication to a request will result in the consumer user's access token being
    /// set as a bearer token in the authorization header of the request.
    case consumer

    /// The swoosh authentication is intended to be used by all OAuth2 authenticated Nike services that support both
    /// Swoosh and consumer authentication. Adding this authentication to a request will result in the swoosh user's
    /// access token being set as a bearer token in the authorization header of the request.
    case swoosh

    /// The swoosh with consumer fallback authentication is intended to be used when you want to authenticate first
    /// with swoosh if available, then fallback to consumer authentication.
    case swooshWithConsumerFallback

    /// The consumer with no auth fallback authentication is intended to be used when you want to authenticate first
    /// with consumer authentication if available, then fallback to no authentication.
    case consumerWithNoAuthFallback

    /// The swoosh with consumer with no auth fallback authentication is intended to be used when you want to
    /// authenticate first with swoosh authentication if available, then fallback to consumer authentication if
    /// available, and finally fallback to no authentication.
    case swooshWithConsumerWithNoAuthFallback

    /// The retail cloud authentication is intended to be used by all OAuth2 authenticated Nike retail services that
    /// support cloud login. Adding this authentication to a request will result a bearer token being added to the
    /// authorization header of the request.
    case retailCloud

    /// The retail device authentication is intended to be used by all OAuth2 authenticated Nike retail services that
    /// support device JWT authentication. Adding this authentication to a request will result a bearer token being
    /// added to the authorization header of the request.
    case retailDevice

    /// The retail cloud override authentication is similar to `retailCloud` authentication, but is intended to be used
    /// by any cloud request that requires elevate permissions, e.g., Manager Approval.
    case retailCloudOverride
}
