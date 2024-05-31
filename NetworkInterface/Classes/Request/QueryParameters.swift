//
//  QueryParameters.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/20/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// A convenience type for collecting query parameter key-value pairs using URLQueryItems, tuples, arrays and
/// dictionaries along with various functional operators.
public struct QueryParameters: ExpressibleByDictionaryLiteral {
    /// The key type of the dictionary literal is a `String`.
    public typealias Key = String

    /// The value type of the dictionary literal is a `String`.
    public typealias Value = String

    /// Enumerates different character sets for query string escaping.
    public enum CharacterEscaping {
        /// No character escaping is performed. Typically used when the caller has preemptively escaped the query keys
        /// and values.
        case none // swiftlint:disable:this discouraged_none_name

        /// Uses the same character set defined in Apple's URLQueryItem. This set closley matches RFC 3986. It is
        /// suitable for services that do not have custom conventions for symbol characters (i.e. the service
        /// interperating '+' as whitespace).
        case standard

        /// Uses the same character set defined in Alamofire. This set is more extensive than required by RFC 3986. It
        /// is suitable for encoding a fully-qualified URL in a query parameter, or when the service has custom
        /// conventions for symbol characters (i.e. the service interperating '+' as whitespace).
        case strict

        /// Used to specify a custom character set escaping.
        case custom(CharacterSet)

        /// The allowed character set for the respective character escaping case.
        public var allowedCharacterSet: CharacterSet {
            switch self {
            case .none:
                return CharacterSet().inverted

            case .standard:
                var allowedSet = CharacterSet.urlQueryAllowed
                allowedSet.remove(charactersIn: "&=")
                return allowedSet

            case .strict:
                var allowedSet = CharacterSet.urlQueryAllowed
                allowedSet.remove(charactersIn: "&=:[]@!$'()*+,;")
                return allowedSet

            case .custom(let allowedSet):
                return allowedSet
            }
        }
    }

    // MARK: Properties

    /// Returns the total number of query parameters stored.
    public var count: Int { parameters.count }

    /// Returns true if there are no query parameters stored, false otherwise.
    public var isEmpty: Bool { parameters.isEmpty }

    /// Returns the internal query parameters as an array of `URLQueryItem` instances.
    public var queryItems: [URLQueryItem] { parameters.map(URLQueryItem.init) }

    /// The character escaping used on the query string keys and values.
    public var characterEscaping: CharacterEscaping = .strict

    private(set) var parameters: [(String, String)] = []

    // MARK: Initialization

    /// Creates a `QueryParameters` instance from the specified query items array.
    ///
    /// - Parameter queryItems: The query items to store as query parameters.
    public init(queryItems: [URLQueryItem]) {
        queryItems.forEach { self[$0.name] = $0.value }
    }

    /// Creates a `QueryParameters` instance from the specified tuple array of key-value pairs.
    ///
    /// - Parameter elements: The key-value pairs to store as query parameters.
    public init(array elements: [(String, String)]) {
        parameters.append(contentsOf: elements)
    }

    /// Creates a `QueryParameters` instance from the specified tuple array of key-value pairs.
    ///
    /// - Parameter elements: The key-value pairs to store as query parameters.
    public init(dictionaryLiteral elements: (String, String)...) {
        parameters.append(contentsOf: elements)
    }

    /// Creates a `QueryParameters` instance from the specified dictionary of key-value pairs.
    ///
    /// - Parameter elements: The key-value pairs to store as query parameters.
    public init(dictionary elements: [String: String]) {
        elements.forEach { parameters.append($0) }
    }

    // MARK: Accessors

    /// Gets-sets the parameter value for the specified key.
    ///
    /// If there are multiple values for the specified key, the values are returned as a comma-separated list in
    /// the order in which they were set.
    ///
    /// - Parameter key: The parameter key to get-set the value for.
    ///
    /// - Complexity: O(1) on set, O(n^2) on get in worst case.
    public subscript(key: String) -> String? {
        get {
            let values = parameters.filter { $0.0 == key }.map { $0.1 }
            guard !values.isEmpty else { return nil }

            return values.joined(separator: ", ")
        }
        set {
            if let newValue = newValue {
                parameters.append((key, newValue))
            } else {
                var indices: [Int] = []

                for (index, parameter) in parameters.enumerated() where parameter.0 == key {
                    indices.append(index)
                }

                for index in indices.reversed() {
                    parameters.remove(at: index)
                }
            }
        }
    }

    /// Adds the new element to the end of the internal parameter array.
    ///
    /// - Parameter newElement: The element to append to the array.
    ///
    /// - Complexity: O(1).
    public mutating func append(_ newElement: (String, String)) {
        parameters.append(newElement)
    }

    /// Adds the elements to the end of the internal parameter array.
    ///
    /// - Parameter newElements: The elements to append to the array.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the new elements array.
    public mutating func append(contentsOf newElements: [(String, String)]) {
        parameters.append(contentsOf: newElements)
    }

    /// Returns whether the key is contained inside the internal parameter array.
    ///
    /// - Parameter key: The key to check for.
    ///
    /// - Complexity: O(n), with some more.
    ///
    /// - Returns: `true` if the key is contained inside the internal parameter array, `false` otherwise.
    public func contains(_ key: String) -> Bool {
        for parameter in parameters where parameter.0 == key {
            return true
        }

        return false
    }

    /// Returns the query string representing the internal parameter array.
    ///
    /// - Complexity: O(n).
    ///
    /// - Returns: The query string.
    public func queryString() throws -> String? {
        guard !parameters.isEmpty else { return nil }

        let pairs = try parameters.map { "\(try escape($0.0))=\(try escape($0.1))" }

        return pairs.joined(separator: "&")
    }

    // MARK: Private - Escaping

    private func escape(_ string: String) throws -> String {
        guard
            let result = string.addingPercentEncoding(withAllowedCharacters: characterEscaping.allowedCharacterSet)
        else {
            throw RequestError.initialization(.parameterEncodingFailed("Failed to escape query parameter: \(string)"))
        }

        return result
    }
}

// MARK: - Codable

extension QueryParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case characterEscaping
        case parameters
    }

    private struct Parameter: Codable {
        let key: String
        let value: String

        init(pair: (String, String)) {
            key = pair.0
            value = pair.1
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let codableParameters = try container.decode([Parameter].self, forKey: .parameters)

        characterEscaping = try container.decode(CharacterEscaping.self, forKey: .characterEscaping)
        parameters = codableParameters.map { ($0.key, $0.value) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let codableParameters = parameters.map(Parameter.init)

        try container.encode(characterEscaping, forKey: .characterEscaping)
        try container.encode(codableParameters, forKey: .parameters)
    }
}

extension QueryParameters.CharacterEscaping: Codable {
    enum CodingKeys: String, CodingKey {
        case characterEscapingCase = "case"
        case characterSet
    }

    private enum CharacterEscapingCase: String, Codable {
        case none // swiftlint:disable:this discouraged_none_name
        case standard
        case strict
        case custom
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let characterEscapingCase = try container.decode(CharacterEscapingCase.self, forKey: .characterEscapingCase)

        switch characterEscapingCase {
        case .none:
            self = .none

        case .standard:
            self = .standard

        case .strict:
            self = .strict

        case .custom:
            let characterSet = try container.decode(CharacterSet.self, forKey: .characterSet)
            self = .custom(characterSet)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let characterEscapingCase: CharacterEscapingCase

        switch self {
        case .none:
            characterEscapingCase = .none

        case .standard:
            characterEscapingCase = .standard

        case .strict:
            characterEscapingCase = .strict

        case .custom(let characterSet):
            characterEscapingCase = .custom
            try container.encode(characterSet, forKey: .characterSet)
        }

        try container.encode(characterEscapingCase, forKey: .characterEscapingCase)
    }
}

// MARK: - Equatable

extension QueryParameters.CharacterEscaping: Equatable {
    public static func == (lhs: QueryParameters.CharacterEscaping, rhs: QueryParameters.CharacterEscaping) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):                                       return true
        case (.standard, .standard):                               return true
        case (.strict, .strict):                                   return true
        case let (.custom(lhsCharacters), .custom(rhsCharacters)): return lhsCharacters == rhsCharacters
        default:                                                   return false
        }
    }
}

// MARK: - Operators

/// Appends the right-hand side key-value pair tuple to the left-hand side query parameters.
///
/// - Parameters:
///   - lhs: The query parameters to append to.
///   - rhs: The key-value pair tuple to append as a query parameter.
public func += (lhs: inout QueryParameters, rhs: (String, String)) {
    lhs.append(rhs)
}

/// Appends the right-hand side array of key-value pair tuples to the left-hand side query parameters.
///
/// - Parameters:
///   - lhs: The query parameters to append to.
///   - rhs: The array of key-value pair tuples to append as query parameters.
public func += (lhs: inout QueryParameters, rhs: [(String, String)]) {
    rhs.forEach { lhs.append($0) }
}

/// Appends the right-hand side query parameters to the left-hand side query parameters.
///
/// - Parameters:
///   - lhs: The query parameters to append to.
///   - rhs: The query parameters to add.
public func += (lhs: inout QueryParameters, rhs: QueryParameters) {
    lhs.append(contentsOf: rhs.parameters)
}

// MARK: - URLComponents

extension URLComponents {
    /// Returns underlying query items as query parameters and sets query items with specified query parameters.
    public var queryParameters: QueryParameters? {
        get {
            guard let queryItems = queryItems else { return nil }
            return QueryParameters(queryItems: queryItems)
        }
        set {
            queryItems = newValue?.queryItems
        }
    }
}

// MARK: - Bool String Conversion

extension Bool {
    /// Returns the textual representation of the `Bool` as a "true" or "false" `String`.
    public var asString: String { self == true ? "true" : "false" }
}
