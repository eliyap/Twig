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
    return try decodeFailableArray(from: data)
}

/// Combine approach.
public func timelinePublisher(credentials: OAuthCredentials) -> AnyPublisher<[RawTweet], Error> {
    let request = timelineRequest(credentials: credentials)
    return URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { (data, _) in try decodeFailableArray(from: data) }
        .eraseToAnyPublisher()
}

// MARK: - Guts
/// Decode JSON array.
/// If there are malformed values in the array,
/// salvage the good ones, and cause a dev crash for the bad ones.
internal func decodeFailableArray<T: Decodable>(from data: Data) throws -> [T] {
    /// Attempt to decode each item, replacing failures with `nil`.
    let failables = try JSONDecoder().decode([Failable<T>].self, from: data)
    
    /// Filter out `nil` values in production.
    return failables.compactMap { (failable) -> T? in
        if let item = failable.item {
            return item
        } else {
            #if DEBUG
            /// Intentionally crash to reveal error.
            _ = try! JSONDecoder().decode([T].self, from: data)
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
