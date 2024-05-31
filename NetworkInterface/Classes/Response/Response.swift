//
//  Response.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/21/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Used to store all data associated with a serialized response of a request.
public struct Response<Success, Failure: NIError> {
    /// The url request sent to the server.
    public let request: URLRequest?

    /// The server's response to the url request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    /// The final metrics of the request lifecycle.
    public let metrics: TaskMetrics?

    /// The time taken to serialize the response.
    public let serializationDuration: TimeInterval

    /// The result of response serialization.
    public let result: Result<Success, Failure>

    /// Creates a `DataResponse` instance with the specified parameters derived from response serialization.
    ///
    /// - Parameters:
    ///   - request:               The url request sent to the server.
    ///   - response:              The url response from the server.
    ///   - data:                  The data returned by the server.
    ///   - metrics:               The metrics of the request lifecycle.
    ///   - serializationDuration: The time taken to serialize the response.
    ///   - result:                The result of response serialization.
    public init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        metrics: TaskMetrics?,
        serializationDuration: TimeInterval,
        result: Result<Success, Failure>)
    {
        self.request = request
        self.response = response
        self.data = data
        self.metrics = metrics
        self.result = result
        self.serializationDuration = serializationDuration
    }
}

// MARK: -

extension Response: CustomStringConvertible, CustomDebugStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        result.description
    }

    /// The debug textual representation used when written to an output stream, which includes the URL request, the URL
    /// response, the server data, the duration of the network and serializatino actions, and the response serialization
    /// result.
    public var debugDescription: String {
        var requestDescription = " None"
        var requestBody = " None"
        var responseDescription = " None"
        var responseBody = " None"
        var metricsDescription = " None"

        if let rd = request.map({ "\($0.httpMethod!) \($0)" }) { requestDescription = " \(rd)" }

        if let rb = request?.httpBody.map({ String(decoding: $0, as: UTF8.self) }) { requestBody = "\n\(rb)" }

        let rd: String? = response.map { response in
            var sortedHeadersDescription = response.headers.sorted().description
            if sortedHeadersDescription.isEmpty { sortedHeadersDescription = "[:]" }

            return """
                - Status Code: \(response.statusCode)
                - Headers: \(sortedHeadersDescription)
                """
        }

        if let rd = rd { responseDescription = "\n\(rd)" }

        if let rb = data.map({ String(decoding: $0, as: UTF8.self) }) { responseBody = "\n\(rb)" }

        if let md = metrics.map({ " \($0.taskInterval.duration)s" }) { metricsDescription = md }

        return """
            [Request]:\(requestDescription)
            [Request Body]:\(requestBody)
            [Response]:\(responseDescription)
            [Response Body]:\(responseBody)
            [Data]: \(data?.description ?? "None")
            [Network Duration]:\(metricsDescription)
            [Serialization Duration]: \(serializationDuration)s
            [Result]: \(result.description)
            """
    }
}

// MARK: - Functional Extensions

extension Response {
    /// Returns a new `Response`, mapping any success value using the given transformation.
    ///
    /// Use this method when you need to transform the value of a `Response` instance when it represents a success.
    /// The following example transforms the integer success value of the result into a string:
    ///
    ///     func getTotalPoints() -> Response<Int, RequestError> { /* ... */ }
    ///
    ///     let integerResponse = getTotalPoints()
    ///     // integerResponse.result == .success(5)
    ///     let stringResponse = integerResponse.map { String($0) }
    ///     // stringResponse.result == .success("5")
    ///
    /// - Parameter transform: A closure that takes the success value of this instance and returns a new success value.
    ///
    /// - Returns: A `Response` instance with a result of evaluating the transform as the new success value if this
    ///            instance represents a success.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Response<NewSuccess, Failure> {
        withResult(result.map(transform))
    }

    /// Returns a new `Response`, mapping any failure value using the given transformation.
    ///
    /// Use this method when you need to transform the value of a `Response` instance when it represents a failure.
    /// The following example transforms the error value of a result by wrapping it in a custom Error type:
    ///
    ///     struct DatedError: NIError {
    ///         let error: RequestError
    ///         let date: Date
    ///
    ///         init(_ error: RequestError) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     let response: Response<Int, RequestError> = // ...
    ///     // response.result == .failure(<error value>)
    ///     let responseWithDatedError = response.mapError { DatedError($0) }
    ///     // responseWithDatedError.result == .failure(DatedError(error: <error value>, date: <date>))
    ///
    /// - Parameter transform: A closure that takes the failure value of this instance and returns a new failure value.
    ///
    /// - Returns: A `Response` instance with a result of evaluating the transform as the new failure value if this
    ///            instance represents a failure.
    public func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Response<Success, NewFailure> {
        withResult(result.mapError(transform))
    }

    /// Returns a new `Response` mapping the `NewSuccess` and `NewFailure` types to `.success(value)`.
    ///
    /// Use this method when you need to transform both the `Success` and `Failure` types of the `Response` when it
    /// represents a success. The following example transforms the contact success value of the result into a name
    /// result with the new `DatedError` error type:
    ///
    ///     struct DatedError: NIError {
    ///         let error: RequestError
    ///         let date: Date
    ///
    ///         init(_ error: RequestError) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     struct Contact {
    ///         let contactID: String
    ///         let name: Name
    ///     }
    ///
    ///     struct Name {
    ///         let firstName: String
    ///         let lastName: String
    ///     }
    ///
    ///     func getContact() -> Response<Contact, RequestError> { /* ... */ }
    ///
    ///     let contactResponse = getContact()
    ///     // contactResponse.result == .success(Contact(contactID: <contact id>, name: Name(/* ... */)))
    ///
    ///     if case .success(let contact) = contactResponse.result {
    ///         let nameResponse: Response<Name, DatedError> = contactResponse.withSuccess(contact.name)
    ///         // nameResponse.result == .success(Name(/* ... */))
    ///     }
    ///
    /// - Parameter value: The new success value.
    ///
    /// - Returns: A `Response` instance with a result of `.success(value)` matching the `NewSuccess` and
    ///            `NewFailure` types.
    public func withSuccess<NewSuccess, NewFailure>(_ value: NewSuccess) -> Response<NewSuccess, NewFailure> {
        withResult(.success(value))
    }

    /// Returns a new `Response` mapping the `NewSuccess` and `NewFailure` types to `.failure(error)`.
    ///
    /// Use this method when you need to transform both the `Success` and `Failure` types of the `Response` when it
    /// represents a failure. The following example transforms the error failure value of the result into a new
    /// `DatedError` type with a `Name` success type:
    ///
    ///     struct DatedError: NIError {
    ///         let error: RequestError
    ///         let date: Date
    ///
    ///         init(_ error: RequestError) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     struct Contact {
    ///         let contactID: String
    ///         let name: Name
    ///     }
    ///
    ///     struct Name {
    ///         let firstName: String
    ///         let lastName: String
    ///     }
    ///
    ///     func getContact() -> Response<Contact, RequestError> { /* ... */ }
    ///
    ///     let contactResponse = getContact()
    ///     // contactResponse.result == .failure(<error value>)
    ///
    ///     if case .failure(let error) = contactResponse.result {
    ///         let nameResponse: Response<Name, DatedError> = contactResponse.withFailure(DatedError(error))
    ///         // nameResponse.result == .failure(.failure(DatedError(error: <error value>, date: <date>)))
    ///     }
    ///
    /// - Parameter error: The new failure value.
    ///
    /// - Returns: A `Response` instance with a result of `.failure(error)` matching the `NewSuccess` and `NewFailure`
    ///            types.
    public func withFailure<NewSuccess, NewFailure>(_ error: NewFailure) -> Response<NewSuccess, NewFailure> {
        withResult(.failure(error))
    }

    /// Returns a new `Response` replacing the result and mapping to the `NewSuccess` and `NewFailure` types.
    ///
    /// Use this method when you need to replace both the `Success` and `Failure` types of the `Response` along with
    /// the `Result` itself. The following example replaces the `Result<Contact, RequestError>` of the `Response` with
    /// a new `Result<Name, DatedError>`:
    ///
    ///     struct DatedError: NIError {
    ///         let error: RequestError
    ///         let date: Date
    ///
    ///         init(_ error: RequestError) {
    ///             self.error = error
    ///             self.date = Date()
    ///         }
    ///     }
    ///
    ///     struct Contact {
    ///         let contactID: String
    ///         let name: Name
    ///     }
    ///
    ///     struct Name {
    ///         let firstName: String
    ///         let lastName: String
    ///     }
    ///
    ///     func getContact() -> Response<Contact, RequestError> { /* ... */ }
    ///
    ///     let contactResponse = getContact()
    ///     // contactResponse.result == .success(Contact(contactID: <contact id>, name: Name(/* ... */)))
    ///
    ///     let nameResult = contactResponse.result
    ///         .map { $0.name }
    ///         .mapError { DatedError($0)
    ///
    ///     let nameResponse: Response<Name, DatedError> = contactResponse.withResult(nameResult)
    ///     // nameResponse.result == .success(Name(/* ... */))
    ///
    /// - Parameter result: The new result value.
    ///
    /// - Returns: A `Response` instance with the new result matching the `NewSuccess` and `NewFailure` types.
    public func withResult<NewSuccess, NewFailure>(_ result: Result<NewSuccess, NewFailure>) -> Response<NewSuccess, NewFailure> {
        Response<NewSuccess, NewFailure>(
            request: request,
            response: response,
            data: data,
            metrics: metrics,
            serializationDuration: serializationDuration,
            result: result
        )
    }
}

// MARK: -

extension Result {
    fileprivate var description: String {
        switch self {
        case .success(let value): return "SUCCESS: \(value)"
        case .failure(let error): return "FAILURE: \(error)"
        }
    }
}
