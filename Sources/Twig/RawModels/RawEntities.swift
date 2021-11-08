import Foundation

// MARK: - v2 Entities

public struct RawEntities: Codable {
    public let annotations: [RawAnnotation]?
    public let mentions: [RawMention]?
    public let hashtags: [RawTag]?
    public let urls: [RawURL]?
}

public struct RawMention: Codable {
    public let start: Int
    public let end: Int
    public let id: String
    public let username: String
}

public struct RawTag: Codable {
    public let start: Int
    public let end: Int
    public let tag: String
}

public struct RawURL: Codable {
    public let start: Int
    public let end: Int
    public let url: String
    public let expanded_url: String
    public let display_url: String
}

public struct RawAnnotation: Codable {
    public let start: Int
    public let end: Int
    public let normalized_text: String
    public let probability: Double

    /// - Note: might be an enum, but due to unknown values, it's not possible to decode it.
    public let type: String
}
