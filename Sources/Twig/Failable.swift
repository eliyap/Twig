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

/// Decode JSON array.
/// If there are malformed values in the array,
/// salvage the good ones, and cause a dev crash for the bad ones.
internal func decodeFailableArray<T: Decodable>(from data: Data) throws -> [T] {
    /// Attempt to decode each item, replacing failures with `nil`.
    let failables = try JSONDecoder().decode([Failable<T>].self, from: data)
    
    /// Filter out `nil` values in production.
    return failables.compactMap { (failable) -> T? in
        if let item = failable.item {
            return item
        } else {
            #if DEBUG
            /// Intentionally crash to reveal error.
            _ = try! JSONDecoder().decode([T].self, from: data)
            #endif
            return nil
        }
    }
}
