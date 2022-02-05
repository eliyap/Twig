//
//  Statuses.swift
//  
//
//  Created by Secret Asian Man Dev on 4/2/22.
//

import Foundation

/// A structure focused on receiving videos and GIFs.
public struct RawV1MediaTweet: Decodable, Sendable {
    let extended_entities: RawExtendedEntities?
}

public enum StatusesEndpoint {
    public static let baseURL = "https://api.twitter.com/1.1/statuses/lookup.json"
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/v1/tweets/post-and-engage/api-reference/get-statuses-lookup
    /// Limited to 900 requests / 15 min.
    public static let interval: TimeInterval = (15.0 * 60) / 900
}

public func requestv11Statuses(credentials: OAuthCredentials, ids: [String]) async throws -> Void {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.v1dot1Format)
    
    let request = authorizedRequest(
        endpoint: StatusesEndpoint.baseURL,
        method: .GET,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            "id": ids.joined(separator: ","),
            "include_entities": "true",
            "tweet_mode": "extended",
        ])
    )
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            TwigLog.error("""
                \(#function) returned with bad status code
                - code: \(response.statusCode)
                - dict: \(dict as Any)
                """)
            throw TwigError.badStatusCode(code: response.statusCode)
        }
    }
    
    let dict: [Any] = try! JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
    print(dict)
    
    let blob = try decoder.decode([Failable<RawV1MediaTweet>].self, from: data)
//    return blob.compactMap(\.item).map({RawV1TweetSendable($0)})
    
    
}
