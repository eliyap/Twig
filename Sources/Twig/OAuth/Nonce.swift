//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/// Use the UUID function to create a number-used-once
/// by stripping out the `-`'s.
internal func nonce() -> String {
    UUID().uuidString.replacingOccurrences(of: "-", with: "")
}
