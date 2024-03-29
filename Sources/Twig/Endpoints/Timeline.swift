//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation
import Combine

/// `async` approach.
public func timeline(credentials: OAuthCredentials, sinceID: String?, maxID: String?) async throws -> [RawV1TweetSendable] {
    let request = timelineRequest(credentials: credentials, sinceID: sinceID, maxID: maxID)
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
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.v1dot1Format)
    let blob = try decoder.decode([Failable<RawV1Tweet>].self, from: data)
    return blob.compactMap(\.item).map({RawV1TweetSendable($0)})
}

// MARK: - Guts
/// Docs: https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/guides/working-with-timelines
internal func timelineRequest(credentials: OAuthCredentials, sinceID: String?, maxID: String?) -> URLRequest {
    let method: HTTPMethod = .GET
    var timelineURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    
    let parameters = signedParameters(
        method: method,
        url: timelineURL,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            /**
             Instead of fetching 20 at a time, fetch the maximum 200 at a time.
             Especially important because `home_timeline` API limit is 15 reqeuests per 15 mins.
             Docs: https://developer.twitter.com/en/docs/twitter-api/v1/tweets/timelines/api-reference/get-statuses-home_timeline
             */
            "count":"200",
            "since_id": sinceID,
            "max_id": maxID,
        ])
    )
    
    /// Formulate request.
    timelineURL.append(contentsOf: "?\(parameters.encodedSortedParameterString())")
    let url = URL(string: timelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    return request
}
