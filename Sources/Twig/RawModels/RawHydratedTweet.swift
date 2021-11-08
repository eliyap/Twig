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
    public let tweets: [Failable<RawHydratedTweet>]?
    public let users: [Failable<RawIncludeUser>]?
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/user
public struct RawIncludeUser: Codable, Sendable, Hashable {
    public let id: String
    
    /// Displayed name.
    /// e.g. Paul Hudson
    public let name: String
    
    /// API v2's alias for v1's `screen_name`.
    /// Twitter Handle. e.g. @twostraws
    public let username: String
}

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
        .entities_mentions_username,
        .referenced_tweets_id_author_id,
    ]
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

protocol ParsableInt: FixedWidthInteger {
    init?<S>(_ text: S, radix: Int) where S : StringProtocol
}

extension Int: ParsableInt { }
extension Int64: ParsableInt { }

extension ParsableInt {
    /// Cause a dev crash if this fails.
    static func devCast(_ str: String) -> Self? {
        if let result = Self(str, radix: 10) {
            #if DEBUG
            assert(false, "Could not cast \(str) to \(Self.self) with max \(max)")
            #endif
            return result
        } else {
            return nil
        }
    }
}
