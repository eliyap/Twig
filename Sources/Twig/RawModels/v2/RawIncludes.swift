//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 23/12/21.
//

import Foundation

internal struct RawIncludes: Decodable {
    public let tweets: [Failable<RawHydratedTweet>]?
    public let users: [Failable<RawUser>]?
    public let media: [Failable<RawIncludeMedia>]?
}

public struct RawIncludeMedia: Decodable, Hashable, Sendable {
    public let media_key: String
    
    public let type: RawIncludeMediaType
    
    /// Pixel Dimensions.
    public let width: Int
    public let height: Int
    
    public let preview_image_url: String?
    public let duration_ms: Int?
    
    public let alt_text: String?
    
    public let url: String?
}

public enum RawIncludeMediaType: String, Decodable, Hashable, Sendable {
    case photo
    case animated_gif
    case video
}
