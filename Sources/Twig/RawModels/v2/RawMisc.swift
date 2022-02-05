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
    let media: [RawExtendedMedia]
}

public struct RawExtendedMedia: Codable, Sendable {
    let id_str: String
    
    let media_url: String
    let media_url_https: String
    let url: String
    let display_url: String
    let expanded_url: String
    
    let type: RawIncludeMediaType
    let video_info: RawVideoInfo
}

public struct RawMediaSizes: Codable, Sendable {
    let thumb: RawMediaSize
    let small: RawMediaSize
    let medium: RawMediaSize
    let large: RawMediaSize
}

public struct RawMediaSize: Codable, Sendable {
    let w: Int
    let h: Int
    let resize: RawResize
}

public enum RawResize: String, Codable, Hashable, Sendable {
    case fit, crop
}

public struct RawVideoInfo: Codable, Sendable {
    let aspect_ratio: [Int]
    
    /// Undocumented optional.
    let duration_millis: Int?
    
    let variants: [RawMediaVariant]
}

public struct RawMediaVariant: Codable, Sendable {
    /// - Note: Bitrate is not present on formats such as `m3u8`.
    ///         https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/extended-entities#tweet-video
    let bitrate: Int?
    let content_type: RawIncludeContentType
    let url: String
}
