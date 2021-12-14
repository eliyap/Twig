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
    let method: HTTPMethod = .GET
    let expansions = RawHydratedTweet.expansions
    let mediaFields = RawHydratedTweet.mediaFields
    var userTimelineURL = "https://api.twitter.com/2/users/\(userID)/tweets"
    
    var extraArgs: [String: String] = [
        TweetExpansion.queryKey: expansions.csv,
        MediaField.queryKey: mediaFields.csv,
    ]
    if let startTime = startTime {
        extraArgs["start_time"] = DateFormatter.iso8601withWholeSeconds.string(from: startTime)
    }
    if let endTime = endTime {
        extraArgs["end_time"] = DateFormatter.iso8601withWholeSeconds.string(from: endTime)
    }
    
    let parameters = signedParameters(method: method, url: userTimelineURL, credentials: credentials, including: extraArgs)
    
    /// Manually construct query string to avoid percent-encoding CSV commas.
    userTimelineURL.append("?\(TweetExpansion.queryKey)=\(expansions.csv)&\(MediaField.queryKey)=\(mediaFields.csv)")
    
    let url = URL(string: userTimelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
