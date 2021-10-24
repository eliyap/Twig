//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/10/21.
//

import Foundation

/// The additional information we may obtain for a Tweet Object.
/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/tweet
public enum TweetField: String {
    case attachments
    case author_id
    case context_annotations
    case conversation_id
    case created_at
    case entities
    case geo
    case in_reply_to_user_id
    case lang
    case non_public_metrics
    case organic_metrics
    case possibly_sensitive
    case promoted_metrics
    case public_metrics
    case referenced_tweets
    case reply_settings
    case source
    case withheld
}
