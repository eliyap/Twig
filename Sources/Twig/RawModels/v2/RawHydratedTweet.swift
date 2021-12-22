//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/10/21.
//

import Foundation

internal struct RawHydratedBlob: Decodable {
    public let data: [Failable<RawHydratedTweet>]?
    public let includes: RawIncludes?
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/tweet
public struct RawHydratedTweet: Codable {
    public let id: String
    public let public_metrics: RawPublicMetrics
    public let created_at: Date
    public let conversation_id: String
    public let author_id: String
    public let source: String
    public let text: String
    public let referenced_tweets: [RawReferencedTweet]?
    public let in_reply_to_user_id: String?
    public let entities: RawEntities?
    public let attachments: RawAttachments?
    
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
        .entities,
    ]
    
    /// The expansions we're usually interested in, and which this object expects that you asked for.
    public static let expansions: Set<TweetExpansion> = [
        .author_id,
        .referenced_tweets_id,
        .in_reply_to_user_id,
        .attachments_media_keys,
        .entities_mentions_username,
        .referenced_tweets_id_author_id,
    ]
    
    public static let mediaFields: Set<MediaField> = [
        .duration_ms,
        .height,
        .width,
        .preview_image_url,
        .alt_text,
        .url,
    ]
}

public struct RawAttachments: Codable, Sendable, Hashable {
    /// - Note: array order reflects the intended image album order.
    public let media_keys: [String]?
    public let poll_ids: [String]?
}

public struct RawReferencedTweet: Codable, Sendable {
    public let id: String
    public let type: RawReferenceType
}

public enum RawReferenceType: String, Codable, Sendable {
    case retweeted
    case replied_to
    case quoted
}

public struct RawPublicMetrics: Codable, Sendable {
    public let like_count: Int
    public let quote_count: Int
    public let reply_count: Int
    public let retweet_count: Int
}

public extension RawHydratedTweet {
    var replyID: String? {
        referenced_tweets?.first(where: {$0.type == .replied_to})?.id
    }
}
