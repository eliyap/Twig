//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/// Docs: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
public struct RawV1User: Codable, Hashable, Sendable {
    public let id: Int
    public let id_str: String
    
    /// Displayed name.
    public let name: String
    
    /// Twitter Handle.
    public let screen_name: String
    
    public let location: String?
    
    /// `derived` ignored.
    
    public let url: String?
    
    /// API describes this as a UTF-8 String.
    public let description: String?
    
    public let protected: Bool
    public let verified: Bool
    public let followers_count: Int
    public let friends_count: Int
    public let listed_count: Int
    public let favourites_count: Int
    public let statuses_count: Int
    public let created_at: String
    
    /// - Note: undocumented nullable.
    public let profile_banner_url: String?
    
    /// - Note: I'm guessing this is nullable.
    public let profile_image_url_https: String?
    
    public let default_profile: Bool
    public let default_profile_image: Bool
    
    /// - Note: may not be present.
    public let withheld_in_countries: [String]?
    
    /// - Note: may not be present.
    public let withheld_scope: String?
}
