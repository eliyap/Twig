import Foundation

public struct RawEntities: Codable {
    public let symbols: [RawTag]
    public let hashtags: [RawTag]
    public let user_mentions: [RawMention]
    public let urls: [RawUrl]
}

public struct RawTag: Codable {
    public let indices: [Int]
    public let text: String
}

public struct RawUrl: Codable {
    public let indices: [Int]
    public let url: String
    public let expanded_url: String
    public let display_url: String
}

public struct RawMention: Codable {
    public let indices: [Int]
    public let id: Int64
    public let id_str: String
    public let name: String
    public let screen_name: String
}