//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/10/21.
//

import Foundation

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
}
