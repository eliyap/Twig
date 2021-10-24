//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/10/21.
//

import Foundation

/// Key to request expansion of a ``TweetField`` into a complete object.
/// Docs: https://developer.twitter.com/en/docs/twitter-api/expansions
public enum TweetExpansion: String {
    case author_id = "author_id"
    case referenced_tweets_id = "referenced_tweets.id"
    case in_reply_to_user_id = "in_reply_to_user_id"
    case attachments_media_keys = "attachments.media_keys"
    case attachments_poll_ids = "attachments.poll_ids"
    case geo_place_id = "geo.place_id"
    case entities_mentions_username = "entities.mentions.username"
    case referenced_tweets_id_author_id = "referenced_tweets.id.author_id"
}
