//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 31/12/21.
//

import Foundation

/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/user
public struct RawIncludeUser: Decodable, Hashable {
    public let id: String
    
    /// Displayed name.
    /// e.g. Paul Hudson
    public let name: String
    
    /// API v2's alias for v1's `screen_name`.
    /// Twitter Handle. e.g. @twostraws
    public let username: String
    
    /// The UTC datetime that the user account was created on Twitter.
    public let created_at: Date
    
    /// User's text profile description (aka bio), if any.
    public let description: String
    
    public let entities: RawEntities?
    
    /// Undocumented optional.
    public let pinned_tweet_id: String?
    
    public let profile_image_url: String
    
    public let protected: Bool
    
    public let url: String
    
    public let verified: Bool
}
