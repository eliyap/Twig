//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

/// Set of parameters to be attached to Twitter API Requests.
internal struct RequestParameters {
    /// Parameters that should be percent encoded.
    public var encodable: [String: String?]
    
    /// Parameters that should **not** be percent encoded.
    public var nonEncodable: [String: String?]
    
    public init(
        encodable: [String: String?] = [:],
        nonEncodable: [String: String?] = [:]
    ) {
        self.encodable = encodable
        self.nonEncodable = nonEncodable
    }
    
    internal static let Discard: (String, String) -> String = { (x, _) in
        Swift.debugPrint("[WARNING], duplicate key: \(x)")
        return x
    }
    
    public mutating func merge(_ other: Self) {
        encodable.merge(other.encodable) { (x, _) in x }
        nonEncodable.merge(other.nonEncodable) { (x, _) in x }
    }
    
    /// Parameters used for OAuth 1.0 Authentication.
    public static let OAuth: Self = .init(encodable: [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ])
    
    /// Merge non-nil values into a string.
    /// Used for composing an OAuth 1.0 signature.
    public func encodedString() -> String {
        encodable.compacted.unsafePercentEncoded()
            .merging(nonEncodable.compacted, uniquingKeysWith: Self.Discard)
            .keySorted()
            .parameterString()
            .addingPercentEncoding(withAllowedCharacters: .twitter)!
    }
}
