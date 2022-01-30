//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/** Docs: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
    Names and types mirror the documented API, to allow for synthesized `Codable` conformance.
 */
public struct RawV1Tweet: Codable {
    public let created_at: Date
    public let id: Int
    public let id_str: String
    public let text: String
    public let source: String
    public let truncated: Bool
    
    /// Replies
    public let in_reply_to_status_id: Int?
    public let in_reply_to_status_id_str: String?
    public let in_reply_to_user_id: Int?
    public let in_reply_to_user_id_str: String?
    public let in_reply_to_screen_name: String?
    
    public let user: RawV1User
    
    /// Location
    public let coordinates: RawCoordinates?
    public let place: RawPlace?
    
    /// Quotes
    public let quoted_status_id: Int?
    public let quoted_status_id_str: String?
    public let is_quote_status: Bool
    public let quoted_status: SkeletonTweet?
    
    public let retweeted_status: SkeletonTweet?
    
    /// Note: This object is only available with the Premium and Enterprise tier products.
    public let quote_count: Int?
    
    /// Note: This object is only available with the Premium and Enterprise tier products.
    public let reply_count: Int?
    
    public let retweet_count: Int
    public let favorite_count: Int?
    
    /// - Note: this value is non-nullable, but may not be present if not requested.
    public let entities: RawV1Entities?
    
    /// - Note: this value is non-nullable, but may not be present if not requested.
    public let extended_entities: RawExtendedEntities?
    
    public let favorited: Bool?
    public let retweeted: Bool
    
    public let possibly_sensitive: Bool?
    
    /// - Note: this value is non-nullable, but may not be present.
    public let filter_level: String?

    /// ignored.
    /// public let lang: String
    
    /// `matching_rules` ignored.
}

/**
 A partial Tweet model, representing quoted tweets and retweets,
 to work around Swift's restriction on recursive data structures.
 */
public struct SkeletonTweet: Codable, Sendable {
    public let created_at: String
    public let id: Int
    public let id_str: String
    public let text: String
    public let source: String
    public let truncated: Bool

    public let user: RawV1User
}
