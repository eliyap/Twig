import Foundation

public struct RawV1Entities: Codable {
    public let symbols: [RawV1Tag]
    public let hashtags: [RawV1Tag]
    public let user_mentions: [RawV1Mention]
    public let urls: [RawV1Url]
}

public struct RawV1Tag: Codable {
    public let indices: [Int]
    public let text: String
}

public struct RawV1Url: Codable {
    public let indices: [Int]
    public let url: String
    public let expanded_url: String
    public let display_url: String
}

public struct RawV1Mention: Codable, Sendable {
    public let indices: [Int]
    public let id: Int
    public let id_str: String
    public let name: String
    public let screen_name: String
}
