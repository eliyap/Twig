//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 31/12/21.
//

import Foundation

/// The additional information we may obtain for a User Object.
/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/user
public enum UserField: String {
    static let queryKey = "user.fields"
    
    case created_at
    case description
    case entities
    case location
    case pinned_tweet_id
    case profile_image_url
    case protected
    case public_metrics
    case url
    case verified
    case withheld
    
    /// The set of fields commonly fetched by our application.
    public static let common: [Self] = [
        .created_at,
        .description,
        .entities,
        .location,
        .pinned_tweet_id,
        .profile_image_url,
        .protected,
        .url,
        .verified,
    ]
}
