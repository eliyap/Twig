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
