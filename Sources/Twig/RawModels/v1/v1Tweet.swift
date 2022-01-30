//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public struct RawV1TweetSendable: Sendable {
    /// Exists for this `Sendable` workaround.
    private let createdIntervalSinceEpoch: TimeInterval
    public var created_at: Date {
        .init(timeIntervalSince1970: createdIntervalSinceEpoch)
    }
    
    public let id: Int
    public let id_str: String
    public let text: String
    public let source: String
    public let truncated: Bool
    public let in_reply_to_status_id: Int?
    public let in_reply_to_status_id_str: String?
    public let in_reply_to_user_id: Int?
    public let in_reply_to_user_id_str: String?
    public let in_reply_to_screen_name: String?
    public let user: RawV1User
    public let coordinates: RawCoordinates?
    public let place: RawPlace?
    public let quoted_status_id: Int?
    public let quoted_status_id_str: String?
    public let is_quote_status: Bool
    public let quoted_status: SkeletonTweet?
    public let retweeted_status: SkeletonTweet?
    public let quote_count: Int?
    public let reply_count: Int?
    public let retweet_count: Int
    public let favorite_count: Int?
    public let entities: RawV1Entities?
    public let extended_entities: RawExtendedEntities?
    public let favorited: Bool?
    public let retweeted: Bool
    public let possibly_sensitive: Bool?
    public let filter_level: String?
    
    init(_ raw: RawV1Tweet) {
        self.createdIntervalSinceEpoch = raw.created_at.timeIntervalSince1970
        self.id = raw.id
        self.id_str = raw.id_str
        self.text = raw.text
        self.source = raw.source
        self.truncated = raw.truncated
        self.in_reply_to_status_id = raw.in_reply_to_status_id
        self.in_reply_to_status_id_str = raw.in_reply_to_status_id_str
        self.in_reply_to_user_id = raw.in_reply_to_user_id
        self.in_reply_to_user_id_str = raw.in_reply_to_user_id_str
        self.in_reply_to_screen_name = raw.in_reply_to_screen_name
        self.user = raw.user
        self.coordinates = raw.coordinates
        self.place = raw.place
        self.quoted_status_id = raw.quoted_status_id
        self.quoted_status_id_str = raw.quoted_status_id_str
        self.is_quote_status = raw.is_quote_status
        self.quoted_status = raw.quoted_status
        self.retweeted_status = raw.retweeted_status
        self.quote_count = raw.quote_count
        self.reply_count = raw.reply_count
        self.retweet_count = raw.retweet_count
        self.favorite_count = raw.favorite_count
        self.entities = raw.entities
        self.extended_entities = raw.extended_entities
        self.favorited = raw.favorited
        self.retweeted = raw.retweeted
        self.possibly_sensitive = raw.possibly_sensitive
        self.filter_level = raw.filter_level
    }
}

/** Docs: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
    Names and types mirror the documented API, to allow for synthesized `Codable` conformance.
 */
internal struct RawV1Tweet: Codable {
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
