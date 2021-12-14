//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation
import Combine

/// `async` approach.
public func timeline(credentials: OAuthCredentials, sinceID: String?, maxID: String?) async throws -> [RawV1Tweet] {
    let request = timelineRequest(credentials: credentials, sinceID: sinceID, maxID: maxID)
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    do {
        return try decodeFailableArray(from: data)
    } catch {
        Swift.debugPrint("Failed to fetch v1.1 timeline.")
        if let response = response as? HTTPURLResponse {
            Swift.debugPrint("Timeline fetch failed with code \(response.statusCode).")
        }
        return []
    }
}

/// Combine approach.
public func timelinePublisher(credentials: OAuthCredentials, sinceID: String?, maxID: String?) -> AnyPublisher<[RawV1Tweet], Error> {
    let request = timelineRequest(credentials: credentials, sinceID: sinceID, maxID: maxID)
    return URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { (data, _) in try decodeFailableArray(from: data) }
        .eraseToAnyPublisher()
}

// MARK: - Guts
/// Docs: https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/guides/working-with-timelines
internal func timelineRequest(credentials: OAuthCredentials, sinceID: String?, maxID: String?) -> URLRequest {
    let method: HTTPMethod = .GET
    var timelineURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    
    /**
     Instead of fetching 20 at a time, fetch the maximum 200 at a time.
     Especially important because `home_timeline` API limit is 15 reqeuests per 15 mins.
     Docs: https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-home_timeline
     */
    var extraArgs: [String: String] = ["count":"200"]
    if let sinceID = sinceID {
        extraArgs["since_id"] = sinceID
    }
    if let maxID = maxID {
        extraArgs["max_id"] = maxID
    }
    let parameters = signedParameters(method: method, url: timelineURL, credentials: credentials, including: extraArgs)
    
    /// Formulate request.
    timelineURL.append(contentsOf: "?\(parameters.encodedSortedParameterString())")
    let url = URL(string: timelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    return request
}
