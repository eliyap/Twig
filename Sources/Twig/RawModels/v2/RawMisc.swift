//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public struct RawCoordinates: Codable, Sendable {
    /// Incomplete...
}

public struct RawPlace: Codable, Sendable {
    /// Incomplete...
}

public struct RawExtendedEntities: Codable, Sendable {
    public let media: [RawExtendedMedia]
}

public struct RawExtendedMedia: Codable, Sendable {
    public let id_str: String
    
    public let media_url: String
    public let media_url_https: String
    public let url: String
    public let display_url: String
    public let expanded_url: String
    
    public let type: RawIncludeMediaType
    
    /// Not present when media is a `photo`.
    public let video_info: RawVideoInfo?
}

public struct RawMediaSizes: Codable, Sendable {
    public let thumb: RawMediaSize
    public let small: RawMediaSize
    public let medium: RawMediaSize
    public let large: RawMediaSize
}

public struct RawMediaSize: Codable, Sendable {
    public let w: Int
    public let h: Int
    public let resize: RawResize
}

public enum RawResize: String, Codable, Hashable, Sendable {
    case fit, crop
}

public struct RawVideoInfo: Codable, Sendable {
    public let aspect_ratio: [Int]
    
    /// Undocumented optional.
    public let duration_millis: Int?
    
    public let variants: [RawMediaVariant]
}

public struct RawMediaVariant: Codable, Sendable {
    /// - Note: Bitrate is not present on formats such as `m3u8`.
    ///         https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities#tweet-video
    public let bitrate: Int?
    public let content_type: RawIncludeContentType
    public let url: String
}
