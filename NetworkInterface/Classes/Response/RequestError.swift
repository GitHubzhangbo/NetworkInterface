//
//  RequestError.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/20/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// The root error type vended by all NetworkInterface APIs.
public protocol NIError: Error, CustomStringConvertible {}

/// The error type used to represent all possible failure scenarios throughout the request lifecycle.
public enum RequestError: NIError {
    /// The initialization of the url request failed.
    case initialization(InitializationFailure)

    /// A network error occurred when executing the request.
    case network(URLError)

    /// An authentication error occurred when attempting to authenticate the request.
    case authentication(AuthenticationFailure)

    /// Response validation failed.
    case validation(ValidationFailure)

    /// Response serialization failed.
    case serialization(SerializationFailure)

    /// An unknown error occurred.
    case unknown(Error)

    /// The underlying reason an `.initialization` error occurred.
    public enum InitializationFailure {
        /// The initialization of the url request failed.
        case initializationFailed(_ description: String)

        /// The initialization of the url request failed trying to encode parameters.
        case parameterEncodingFailed(_ description: String)

        /// The initialization of the url request failed trying to encode multipart form data.
        case multipartEncodingFailed(_ description: String)
    }

    /// The underlying reason an `.authentication` error occurred.
    public enum AuthenticationFailure {
        /// The required credential was missing.
        case missingCredential

        /// The required authentication plugin was missing.
        case missingPlugin(_ description: String)

        /// The attempts to refresh the credential exceeded the maximum threshold within the alotted timeframe.
        case excessiveRefresh

        /// The refresh operation for the credential failed.
        case refreshFailed(_ description: String)

        /// The authentication operation failed.
        case authenticationFailed(_ description: String)
    }

    /// The underlying reason an `.validation` error occurred.
    public enum ValidationFailure {
        /// The underlying url session was invalided.
        case sessionInvalidated

        /// The response status code was invalid.
        case invalidStatusCode(responseStatusCode: Int)

        /// The response content type was invalid.
        case invalidContentType(responseContentType: String? = nil, acceptableContentTypes: [String])

        /// The response from the server was missing required headers.
        case missingRequiredHeaders(_ missingRequiredHeaders: [String])

        /// The server trust evaluation of the server's certificate chain failed.
        case serverTrustEvaluationFailed(_ description: String)

        /// The validation of the response from the server failed.
        case validationFailed(description: String, error: Error?)
    }

    /// The underlying reason an `.serialization` error occurred.
    public enum SerializationFailure {
        /// A decoder failed to decode the response data from the server.
        case decodingFailed(_ error: DecodingError)

        /// The response serializer failed to serialize the response data from the server.
        case serializationFailed(description: String, error: Error?)
    }

    public var description: String {
        switch self {
        case .initialization(let failure):
            return "initialization error: \(failure)"

        case .network(let urlError):
            return "network error: \(urlError)"

        case .authentication(let failure):
            return "authentication error: \(failure)"

        case .validation(let failure):
            return "validation error: \(failure)"

        case .serialization(let failure):
            return "serialization error: \(failure)"

        case .unknown(let error):
            return "unknown error: \(error)"
        }
    }
}

/// An error type used to represent an error embedded in the response data from a server.
public protocol ServiceFailure: Error, CustomStringConvertible {}

/// The error type used to represent either a service failure embedded in the response data from the server, or a
/// request error associated with the request lifecycle.
public enum ServiceError<ErrorType: ServiceFailure>: NIError {
    /// A service failure embedded in the response data from the server.
    case serviceFailure(ErrorType)

    /// A request error that occurred during the regular request lifecycle.
    case requestError(RequestError)

    public var description: String {
        switch self {
        case .serviceFailure(let failure):
            return "service failure: \(failure)"

        case .requestError(let error):
            return "request error: \(error)"
        }
    }
}

// MARK: -

extension RequestError {
    /// Returns whether the instance is `.initialization`.
    public var isInitializationError: Bool {
        guard case .initialization = self else { return false }
        return true
    }

    /// Returns whether the instance is `.network`.
    public var isNetworkError: Bool {
        guard case .network = self else { return false }
        return true
    }

    /// Returns whether the instance is `.authentication`.
    public var isAuthenticationError: Bool {
        guard case .authentication = self else { return false }
        return true
    }

    /// Returns whether the instance is `.validation`.
    public var isValidationError: Bool {
        guard case .validation = self else { return false }
        return true
    }

    /// Returns whether the instance is `.serialization`.
    public var isSerializationError: Bool {
        guard case .serialization = self else { return false }
        return true
    }

    /// Returns whether the instance is `.unknown`.
    public var isUnknownError: Bool {
        guard case .unknown = self else { return false }
        return true
    }
}

// MARK: -

extension ServiceError {
    /// Returns whether the instance is `.serviceFailure`.
    public var isServiceFailure: Bool {
        guard case .serviceFailure = self else { return false }
        return true
    }

    /// Returns whether the instance is `.requestError`.
    public var isRequestError: Bool {
        guard case .requestError = self else { return false }
        return true
    }
}

// MARK: -

extension RequestError.InitializationFailure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .initializationFailed(let description):    return "initialization failed: \(description)"
        case .parameterEncodingFailed(let description): return "parameter encoding failed: \(description)"
        case .multipartEncodingFailed(let description): return "multipart encoding failed: \(description)"
        }
    }
}

extension RequestError.AuthenticationFailure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .missingCredential:                     return "missing credential"
        case .missingPlugin(let description):        return "missing plugin: \(description)"
        case .excessiveRefresh:                      return "excessive refresh"
        case .refreshFailed(let description):        return "refresh failed: \(description)"
        case .authenticationFailed(let description): return "authentication failed: \(description)"
        }
    }
}

extension RequestError.ValidationFailure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sessionInvalidated:
            return "session invalidated"

        case .invalidStatusCode(let responseStatusCode):
            return "invalid status code \(responseStatusCode)"

        case .invalidContentType(let responseContentType, let acceptableContentTypes):
            return "invalid content type \(responseContentType ?? "nil"), acceptable content types: \(acceptableContentTypes)"

        case .missingRequiredHeaders(let missingRequiredHeaders):
            return "missing required headers: \(missingRequiredHeaders)"

        case .serverTrustEvaluationFailed(let description):
            return "server trust evaluation failed: \(description)"

        case .validationFailed(let description, _):
            return "validation failed: \(description)"
        }
    }
}

extension RequestError.SerializationFailure: CustomStringConvertible {
    public var description: String {
        switch self {
        case .decodingFailed(let decodingError):
            return "decoding failed: \(decodingError.localizedDescription)"

        case .serializationFailed(let description, _):
            return "serialization failed: \(description)"
        }
    }
}
