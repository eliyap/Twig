//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 22/12/21.
//

import Foundation

public protocol UserIdentifiable {
    var id: String { get }
}

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

extension RawHydratedTweet: ReplyIdentifiable { }
