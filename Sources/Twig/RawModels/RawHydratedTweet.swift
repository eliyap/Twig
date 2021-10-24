//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/10/21.
//

import Foundation

internal struct RawHydratedBlob: Decodable {
    public let data: [Failable<RawHydratedTweet>]
    public let includes: RawIncludes?
}

internal struct RawIncludes: Decodable {
    public let tweets: [Failable<RawHydratedTweet>]
    public let users: [Failable<RawIncludeUser>]
}

public struct RawIncludeUser: Codable {
    public let id: String
    public let name: String
    public let username: String
}

public struct RawHydratedTweet: Codable {
    /// The fields we're usually interested in, and which this object expects that you asked for.
    public static let fields: Set<TweetField> = [
        .author_id,
        .attachments,
        .conversation_id,
        .created_at,
        .in_reply_to_user_id,
        .public_metrics,
        .referenced_tweets,
        .source,
    ]
    
    /// The expansions we're usually interested in, and which this object expects that you asked for.
    public static let expansions: Set<TweetExpansion> = [
        .author_id,
        .referenced_tweets_id,
        .in_reply_to_user_id,
        .entities_mentions_username,
        .referenced_tweets_id_author_id,
    ]
    
    public let id: String
    public let public_metrics: RawPublicMetrics
    public let created_at: String
    public let conversation_id: String
    public let author_id: String
    public let source: String
    public let text: String
    public let referenced_tweets: [RawReferencedTweet]?
    public let in_reply_to_user_id: String?
    // entities here...
}

public struct RawReferencedTweet: Codable {
    public let id: String
    public let type: RawReferenceType
}

public enum RawReferenceType: String, Codable {
    case retweeted
    case replied_to
    case quoted
}

public struct RawPublicMetrics: Codable {
    public let like_count: Int
    public let quote_count: Int
    public let reply_count: Int
    public let retweet_count: Int
}
