//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 22/12/21.
//

import Foundation

/// Describes an object with with a UserID (typically some kind of Twitter User representation).
public protocol UserIdentifiable {
    var id: String { get }
}

extension RawUser: UserIdentifiable { }

/// Describes an object with an identifiable author (typically some kind of Tweet representation).
public protocol AuthorIdentifiable {
    var authorID: String { get }
}

extension RawHydratedTweet: AuthorIdentifiable {
    public var authorID: String { author_id }
}

public protocol ReplyIdentifiable {
    var replyID: String? { get }
}

extension RawHydratedTweet: ReplyIdentifiable {
    public var replyID: String? {
        referenced_tweets?.first(where: {$0.type == .replied_to})?.id
    }
}

public protocol TweetIdentifiable {
    var id: String { get }
}

extension RawHydratedTweet: TweetIdentifiable { }

public protocol RetweetIdentifiable {
    var retweetID: String? { get }
}

extension RawHydratedTweet: RetweetIdentifiable {
    public var retweetID: String? {
        referenced_tweets?.first(where: {$0.type == .retweeted})?.id
    }
}
