//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

fileprivate let DEBUG_DUMP_JSON = true

public func userTimeline(
    userID: String,
    credentials: OAuthCredentials,
    startTime: Date?,
    endTime: Date?
) async throws -> Void {
    let request = userTimelineRequest(userID: userID, credentials: credentials, startTime: startTime, endTime: endTime)
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    if DEBUG_DUMP_JSON {
        let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        print(dict as Any)
    }
    
//    if let response = response as? HTTPURLResponse {
//        Swift.debugPrint("Timeline fetch failed with code \(response.statusCode).")
//    }
    
}

// MARK: - Guts
/// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
internal func userTimelineRequest(
    userID: String,
    credentials: OAuthCredentials,
    startTime: Date?,
    endTime: Date?
) -> URLRequest {
    authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(userID)/tweets",
        method: .GET,
        credentials: credentials,
        nonEncoded: [
            TweetExpansion.queryKey: RawHydratedTweet.expansions.csv,
            MediaField.queryKey: RawHydratedTweet.mediaFields.csv,
            TweetField.queryKey: RawHydratedTweet.fields.csv,
            "start_time": startTime?.formatted(with: .iso8601withWholeSeconds),
            "end_time": endTime?.formatted(with: .iso8601withWholeSeconds),
        ]
    )
}
