//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation
import Combine

/// `async` approach.
public func timeline(credentials: OAuthCredentials) async throws -> [RawTweet] {
    let request = timelineRequest(credentials: credentials)
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    return try decodeTweets(from: data)
}

/// Combine approach.
public func timelinePublisher(credentials: OAuthCredentials) -> AnyPublisher<[RawTweet], Error> {
    let request = timelineRequest(credentials: credentials)
    return URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { (data, _) in try decodeTweets(from: data) }
        .eraseToAnyPublisher()
}

// MARK: - Guts
/// Decode JSON array of Tweets.
/// If there are malformed values in the array,
/// salvage the good ones, and cause a dev crash for the bad ones.
internal func decodeTweets(from data: Data) throws -> [RawTweet] {
    let failables = try JSONDecoder().decode([Failable<RawTweet>].self, from: data)
    return failables.compactMap { (failable) -> RawTweet? in
        if let tweet = failable.item {
            return tweet
        } else {
            #if DEBUG
            /// Intentionally crash to reveal error.
            _ = try! JSONDecoder().decode([RawTweet].self, from: data)
            #endif
            return nil
        }
    }
}

internal func timelineRequest(credentials: OAuthCredentials) -> URLRequest {
    var timelineURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    
    let parameters = signedParameters(method: .GET, url: timelineURL, credentials: credentials)
    
    /// Formulate request.
    timelineURL.append(contentsOf: "?\(parameters.parameterString())")
    let url = URL(string: timelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    
    return request
}
