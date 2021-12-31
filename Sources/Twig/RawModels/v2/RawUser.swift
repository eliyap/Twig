//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 31/12/21.
//

import Foundation

/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/user
public struct RawIncludeUser: Decodable, Sendable, Hashable {
    public let id: String
    
    /// Displayed name.
    /// e.g. Paul Hudson
    public let name: String
    
    /// API v2's alias for v1's `screen_name`.
    /// Twitter Handle. e.g. @twostraws
    public let username: String
}
