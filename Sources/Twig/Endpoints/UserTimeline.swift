//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Combine
import Foundation

fileprivate let DEBUG_DUMP_JSON = false

internal struct RawUserTimelineMetadata: Decodable {
    let newest_id: String
    let next_token: String?
    let oldest_id: String
    let result_count: Int
}

/// The shape of data returned from the User Timeline endpoint.
internal struct RawUserTimelineBlob: Decodable {
    let data: [Failable<RawHydratedTweet>]?
    let meta: RawUserTimelineMetadata
    let includes: RawIncludes?
}

public func userTimeline(
    userID: String,
    credentials: OAuthCredentials,
    startTime: Date?,
    endTime: Date?,
    nextToken: String?
) async throws -> ([RawHydratedTweet], [RawIncludeUser], [RawIncludeMedia], String?) {
    let request = userTimelineRequest(
        userID: userID,
        credentials: credentials,
        startTime: startTime,
        endTime: endTime,
        nextToken: nextToken
    )
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    if DEBUG_DUMP_JSON {
        let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        print(dict as Any)
    }
    
    /// Check and discard response.
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            Swift.debugPrint("User Timeline request returned with status code \(response.statusCode)")
        }
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.iso8601withFractionalSeconds)
    
    /// Unwrap `blob` for general consumption.
    let blob = try decoder.decode(RawUserTimelineBlob.self, from: data)
    let tweets: [RawHydratedTweet] = blob.data?.compactMap(\.item) ?? []
    let users: [RawIncludeUser] = blob.includes?.users?.compactMap(\.item) ?? []
    let media: [RawIncludeMedia] = blob.includes?.media?.compactMap(\.item) ?? []
    
    return (tweets, users, media, blob.meta.next_token)
}

// MARK: - Guts
/// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
internal func userTimelineRequest(
    userID: String,
    credentials: OAuthCredentials,
    startTime: Date?,
    endTime: Date?,
    nextToken: String?
) -> URLRequest {
    authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(userID)/tweets",
        method: .GET,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            /// - Note: data requested should match ``hydratedTweets(credentials:ids:fields:expansions:mediaFields:)`` method.
            TweetExpansion.queryKey: RawHydratedTweet.expansions.csv,
            MediaField.queryKey: RawHydratedTweet.mediaFields.csv,
            TweetField.queryKey: RawHydratedTweet.fields.csv,
            
            /// Defines a time window in which tweets must fall to be included.
            "start_time": startTime?.formatted(with: .iso8601withWholeSeconds),
            "end_time": endTime?.formatted(with: .iso8601withWholeSeconds),
            
            /// Token to pass to receive the next page (if any).
            "pagination_token": nextToken,
            
            /// Request the maximum tweets per page, instead of the default 10.
            /// See docs: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
            "max_results": "\(TweetEndpoint.maxResults)",
        ])
    )
}
