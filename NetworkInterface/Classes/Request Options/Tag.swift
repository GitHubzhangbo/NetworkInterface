//
//  Tag.swift
//  NetworkInterface
//
//  Created by Christian Noon on 8/12/19.
//  Copyright © 2019 Nike. All rights reserved.
//

import Foundation

/// Represents a tag to apply to a request.
public struct Tag {
    /// The raw value of the tag.
    public let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - CaseIterable

extension Tag: CaseIterable {
    public static var allCases: [Tag] { [] }
}

// MARK: - Hashable

extension Tag: Hashable {}
