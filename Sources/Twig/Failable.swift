//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/// Stores a failure as `nil` instead of `throw`-ing.
/// This allows us to salvage some elements in an array containing malformed objects.
/// Source: https://stackoverflow.com/a/46369152/12395667
struct Failable<T: Decodable>: Decodable {
    let item: T?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.item = try? container.decode(T.self)
    }
}
