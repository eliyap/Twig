import Foundation

// MARK: - v2 Entities

public struct RawEntities: Codable {
    public var annotations: [RawAnnotation]?
    public var mentions: [RawMention]?
    public var hashtags: [RawTag]?
    public var urls: [RawURL]?
}

public struct RawMention: Codable, Hashable, Sendable {
    public let start: Int
    public let end: Int
    public let id: String
    public let username: String
}

public struct RawTag: Codable, Hashable, Sendable {
    public let start: Int
    public let end: Int
    public let tag: String
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities#urls
public struct RawURL: Codable, Hashable, Sendable {
    public let start: Int
    public let end: Int
    
    /// `t.co` URL.
    public let url: String
    
    /// URL pasted/typed into Tweet.
    /// Example: `"display_url":"bit.ly/2so49n2"`
    public let display_url: String

    /// Expanded version of `` display_url`` .
    /// Example: `"expanded_url":"http://bit.ly/2so49n2"`
    public let expanded_url: String
    
    /**
     Sometimes extra data is provided.
     - Note: the below fields are not currently being used.
     */
    
    /// Website description text. Typically long.
    public let description: String?
    
    public let unwound_url: String?
    
    /// The title you would see in the tab.
    public let title: String?
    
    /// HTTP Response Code.
    public let status: Int?
}

public struct RawAnnotation: Codable, Hashable, Sendable {
    public let start: Int
    public let end: Int
    public let normalized_text: String
    public let probability: Double

    /// - Note: might be an enum, but due to unknown values, it's not possible to decode it.
    public let type: String
}
