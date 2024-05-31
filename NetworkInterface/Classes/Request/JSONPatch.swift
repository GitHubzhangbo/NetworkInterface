//
//  JSONPatch.swift
//  NetworkInterface
//
//  Created by Christian Noon on 6/17/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// The json patch type acts as a container of json patch operations to perform partial updates to the payload
/// of a PATCH request. Please refer to [RFC 6902](https://tools.ietf.org/html/rfc6902) and the
/// [json patch](http://jsonpatch.com) documentation for more information.
public struct JSONPatch {
    /// The operations that make up the json patch.
    public private(set) var operations: [Operation]

    /// Creates a `JSONPatch` instance from the specified `operations`.
    ///
    /// - Parameter operations: The operations to add to the json patch.
    public init(operations: [Operation] = []) {
        self.operations = operations
    }

    /// Creates a `JSONPatch` instance from the specified `operation`.
    ///
    /// - Parameter operation: The operation to add to the json patch.
    public init(operation: Operation) {
        self.operations = [operation]
    }

    /// Appends the operation to the json patch.
    ///
    /// - Parameters:
    ///   - lhs: The json patch.
    ///   - rhs: The operation to append to the json patch.
    public static func += (lhs: inout JSONPatch, rhs: Operation) {
        lhs.append(rhs)
    }

    /// Appends the operation to the json patch.
    ///
    /// - Parameter operation: The operation to append to the json patch.
    public mutating func append(_ operation: Operation) {
        operations.append(operation)
    }

    /// Generates the http body for the json patch as json encoded data with a Content-Type of "application/json".
    ///
    /// - Returns: The http body.
    ///
    /// - Throws: An `EncodingError` if the encoding fails.
    public func body() throws -> HTTPBody {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let data = try encoder.encode(self)

        return EncodedBody(data: data, contentType: HTTPHeader.Value.ContentType.applicationJSON)
    }
}

// MARK: - Encodable

extension JSONPatch: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(operations)
    }
}

// MARK: - Operation -

extension JSONPatch {
    /// Represents a single json patch operation.
    public struct Operation {
        let encodeClosure: (Encoder) throws -> Void

        init(_ encodable: Encodable) {
            encodeClosure = { encoder in try encodable.encode(to: encoder) }
        }
    }
}

// MARK: - Operation Factory Methods

extension JSONPatch.Operation {
    /// Creates a json patch `add` operation from the specified `path` and `value`.
    ///
    /// See the [add section](http://jsonpatch.com/#add) of the docs for more details.
    ///
    /// - Parameters:
    ///   - path: The path of the value to add.
    ///   - value: The value.
    ///
    /// - Returns: A new json patch add operation.
    public static func add<Value: Encodable>(path: String, value: Value) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<Value>(operation: "add", path: path, value: value))
    }

    /// Creates a json patch `remove` operation from the specified `path`.
    ///
    /// See the [remove section](http://jsonpatch.com/#remove) of the docs for more details.
    ///
    /// - Parameter path: The path of the value to remove.
    ///
    /// - Returns: The new json patch remove operation.
    public static func remove(path: String) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<String>(operation: "remove", path: path))
    }

    /// Creates a json patch `remove` operation from the specified `path`.
    /// The operation is a Nike-specific and it does not follow the JSON Patch spec, since the spec does not define the use
    /// of a `value` for `remove`.
    ///
    /// See the [remove section](http://jsonpatch.com/#remove) of the docs for more details.
    ///
    /// - Parameters:
    ///   - path: The path of the value to remove.
    ///   - value: The value.
    ///
    /// - Returns: The new json patch remove operation.
    public static func remove<Value: Encodable>(path: String, value: Value) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<Value>(operation: "remove", path: path, value: value))
    }

    /// Creates a json patch `replace` operation from the specified `path` and `value`.
    ///
    /// - Parameters:
    ///   - path:  The path of the value to replace.
    ///   - value: The new value.
    ///
    /// - Returns: The new json patch replace operation.
    public static func replace<Value: Encodable>(path: String, value: Value) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<Value>(operation: "replace", path: path, value: value))
    }

    /// Creates a json patch `copy` operation from the specified `fromPath` and `toPath` parameters.
    ///
    /// - Parameters:
    ///   - fromPath: The original path to move.
    ///   - toPath:   The new path to move to.
    ///
    /// - Returns: The new json patch copy operation.
    public static func copy(fromPath: String, toPath: String) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<String>(operation: "copy", path: toPath, from: fromPath))
    }

    /// Creates a json patch `move` operation from the specified `fromPath` and `toPath` parameters.
    ///
    /// - Parameters:
    ///   - fromPath: The path of the value to copy.
    ///   - toPath:   The path to copy the value to.
    ///
    /// - Returns: The new json patch move operation.
    public static func move(fromPath: String, toPath: String) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<String>(operation: "move", path: toPath, from: fromPath))
    }

    /// Creates a json patch `test` operation from the specified `path` and `value`.
    ///
    /// - Parameters:
    ///   - path:  The path of the value to test.
    ///   - value: The value.
    ///
    /// - Returns: The new json patch test operation.
    public static func test<Value: Encodable>(path: String, value: Value) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<Value>(operation: "test", path: path, value: value))
    }

    /// Creates a json patch `merge` operation from the specified `path` and `value`.
    ///
    /// - Parameters:
    ///   - path:  The path of the value to test.
    ///   - value: The value.
    ///
    /// - Returns: The new json patch merge operation.
    public static func merge<Value: Encodable>(path: String, value: Value) -> JSONPatch.Operation {
        JSONPatch.Operation(JSONPatch.AnyOperation<Value>(operation: "merge", path: path, value: value))
    }
}

// MARK: - Operation Encodable

extension JSONPatch.Operation: Encodable {
    public func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

// MARK: - AnyOperation

extension JSONPatch {
    struct AnyOperation<Value: Encodable>: Encodable {
        private enum CodingKeys: String, CodingKey {
            case operation = "op"
            case path
            case value
            case from
        }

        let operation: String
        let path: String
        let value: Value?
        let from: String?

        init(operation: String, path: String, value: Value? = nil, from: String? = nil) {
            self.operation = operation
            self.path = path
            self.value = value
            self.from = from
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(operation, forKey: .operation)
            try container.encode(path, forKey: .path)
            try container.encodeIfPresent(value, forKey: .value)
            try container.encodeIfPresent(from, forKey: .from)
        }
    }
}
