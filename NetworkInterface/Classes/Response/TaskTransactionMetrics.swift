//
//  TaskTransactionMetrics.swift
//  NetworkInterface
//
//  Created by Christian Noon on 4/20/22.
//  Copyright © 2022 Nike. All rights reserved.
//

import Foundation

/// An object that encapsualtes the performance metrics collected by the URL Loading System during the execution of
/// a session task.
///
/// This object is simply a wrapper around `URLSessionTaskTransactionMetrics` that exists as a workaround for Apple
/// deprecating the initializer. We plan to file radars around this limitation in an attempt to get Apple to change
/// course here. These initializers "should" continue to be made available for testing purposes.
public struct TaskTransactionMetrics {
    /// The manner in which a resource is fetched.
    public enum ResourceFetchType: Int {
        /// The manner in which the resource was fetched could not be determined.
        case unknown = 0

        /// The resource was loaded over the network.
        case networkLoad = 1

        /// The resource was pushed by the server to the client.
        case serverPush = 2

        /// The resource was retrieved from the local storage.
        case localCache = 3

        /// Creates a resource fetch type instance.
        public init(type: URLSessionTaskMetrics.ResourceFetchType) {
            switch type {
            case .unknown:     self = .unknown
            case .networkLoad: self = .networkLoad
            case .serverPush:  self = .serverPush
            case .localCache:  self = .localCache
            default:           self = .unknown
            }
        }
    }

    /// The domain resolution protocol.
    public enum DomainResolutionProtocol: Int {
        /// The domain resolution protocol is unknown.
        case unknown = 0

        /// The domain resolution protocol is udp.
        case udp = 1

        /// The domain resolution protocol is tcp.
        case tcp = 2

        /// The domain resolution protocol is tls.
        case tls = 3

        /// The domain resolution protocol is https.
        case https = 4

        /// Creates a `DomainResolutionProtocol` from the specified `URLSessionTaskMetrics.DomainResolutionProtocol`.
        @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        public init(resolutionProtocol: URLSessionTaskMetrics.DomainResolutionProtocol) {
            switch resolutionProtocol {
            case .unknown: self = .unknown
            case .udp:     self = .udp
            case .tcp:     self = .tcp
            case .tls:     self = .tls
            case .https:   self = .https
            default:       self = .unknown
            }
        }
    }

    /// The transaction request.
    public let request: URLRequest

    /// The transaction response.
    public let response: URLResponse?

    /// The time when the task started fetching the resource, from the server or locally.
    public let fetchStartDate: Date?

    /// The time immediately before the task started the name lookup for the resource.
    public let domainLookupStartDate: Date?

    /// The time after the name lookup was completed.
    public let domainLookupEndDate: Date?

    /// The time immediately before the task started establishing a TCP connection to the server.
    public let connectStartDate: Date?

    /// The time immediately before the task started the TLS security handshake to secure the current connection.
    public let secureConnectionStartDate: Date?

    /// The time immediately after the security handshake completed.
    public let secureConnectionEndDate: Date?

    /// The time immediately after the task finished establishing the connection to the server.
    public let connectEndDate: Date?

    /// The time immediately before the task started requesting the resource, regardless of whether it is retrieved
    /// from the server or local resources.
    public let requestStartDate: Date?

    /// The time immediately after the task finished requesting the resource, regardless of whether it was retrieved
    /// from the server or local resources.
    public let requestEndDate: Date?

    /// The time immediately after the task received the first byte of the response from the server or from local
    /// resources.
    public let responseStartDate: Date?

    /// The time immediately after the task received the last byte of the resource.
    public let responseEndDate: Date?

    /// The size of the upload body data, file, or stream, in bytes.
    public let countOfRequestBodyBytesBeforeEncoding: Int64

    /// The number of bytes transferred for the request body.
    public let countOfRequestBodyBytesSent: Int64

    /// The number of bytes transferred for the request header.
    public let countOfRequestHeaderBytesSent: Int64

    /// The size of data delivered to your delegate or completion handler.
    public let countOfResponseBodyBytesAfterDecoding: Int64

    /// The number of bytes transferred for the response body.
    public let countOfResponseBodyBytesReceived: Int64

    /// The number of bytes transferred for the response header.
    public let countOfResponseHeaderBytesReceived: Int64

    /// The network protocol used to fetch the resource.
    public let networkProtocolName: String?

    /// The IP address string of the remote interface for the connection.
    public let remoteAddress: String?

    /// The port number of the remote interface for the connection.
    public let remotePort: Int?

    /// The IP address string of the local interface for the connection.
    public let localAddress: String?

    /// The port number of the local interface for the connection.
    public let localPort: Int?

    /// The TLS cipher suite the task negotiated with the endpoint for the connection.
    public let negotiatedTLSCipherSuite: tls_ciphersuite_t?

    /// The TLS protocol version the task negotiated with the endpoint for the connection.
    public let negotiatedTLSProtocolVersion: tls_protocol_version_t?

    /// A Boolean value that indicates whether the connection operates over a cellular interface.
    public let isCellular: Bool

    /// A Boolean value that indicates whether the connection operates over an expensive interface.
    public let isExpensive: Bool

    /// A Boolean value that indicates whether the connection operates over an interface marked as constrained.
    public let isConstrained: Bool

    /// A Boolean value that indicastes whether the task used a proxy connection to fetch the resource.
    public let isProxyConnection: Bool

    /// A Boolean value that indicates whether the task used a persistent connection to fetch the resource.
    public let isReusedConnection: Bool

    /// A Boolean value that indicates whether the connection uses a successfully negotiated multipath protocol.
    public let isMultipath: Bool

    /// A value that indicates whether the resource was loaded, pushed, or retrieved from the local cache.
    public let resourceFetchType: ResourceFetchType

    /// The domain resolution protocol.
    public let domainResolutionProtocol: DomainResolutionProtocol

    /// Creates a task transaction metrics instance.
    public init(metrics: URLSessionTaskTransactionMetrics) {
        self.request = metrics.request
        self.response = metrics.response
        self.fetchStartDate = metrics.fetchStartDate
        self.domainLookupStartDate = metrics.domainLookupStartDate
        self.domainLookupEndDate = metrics.domainLookupEndDate
        self.connectStartDate = metrics.connectStartDate
        self.secureConnectionStartDate = metrics.secureConnectionStartDate
        self.secureConnectionEndDate = metrics.secureConnectionEndDate
        self.connectEndDate = metrics.connectEndDate
        self.requestStartDate = metrics.requestStartDate
        self.requestEndDate = metrics.requestEndDate
        self.responseStartDate = metrics.responseStartDate
        self.responseEndDate = metrics.responseEndDate
        self.countOfRequestBodyBytesBeforeEncoding = metrics.countOfRequestBodyBytesBeforeEncoding
        self.countOfRequestBodyBytesSent = metrics.countOfRequestBodyBytesSent
        self.countOfRequestHeaderBytesSent = metrics.countOfRequestHeaderBytesSent
        self.countOfResponseBodyBytesAfterDecoding = metrics.countOfResponseBodyBytesAfterDecoding
        self.countOfResponseBodyBytesReceived = metrics.countOfResponseBodyBytesReceived
        self.countOfResponseHeaderBytesReceived = metrics.countOfResponseHeaderBytesReceived
        self.networkProtocolName = metrics.networkProtocolName
        self.remoteAddress = metrics.remoteAddress
        self.remotePort = metrics.remotePort
        self.localAddress = metrics.localAddress
        self.localPort = metrics.localPort
        self.negotiatedTLSCipherSuite = metrics.negotiatedTLSCipherSuite
        self.negotiatedTLSProtocolVersion = metrics.negotiatedTLSProtocolVersion
        self.isCellular = metrics.isCellular
        self.isExpensive = metrics.isExpensive
        self.isConstrained = metrics.isConstrained
        self.isProxyConnection = metrics.isProxyConnection
        self.isReusedConnection = metrics.isReusedConnection
        self.isMultipath = metrics.isMultipath
        self.resourceFetchType = ResourceFetchType(type: metrics.resourceFetchType)

        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.domainResolutionProtocol = DomainResolutionProtocol(resolutionProtocol: metrics.domainResolutionProtocol)
        } else {
            self.domainResolutionProtocol = .unknown
        }
    }
}
