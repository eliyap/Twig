//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

// MARK: - Guts
/// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
internal func userTimelineRequest(
    userID: String,
    credentials: OAuthCredentials,
    startTime: Date?,
    endTime: Date?
) -> URLRequest {
    let method: HTTPMethod = .GET
    var userTimelineURL = "https://api.twitter.com/2/users/\(userID)/tweets"
    
    var extraArgs: [String: String] = [:]
    if let startTime = startTime {
        extraArgs["start_time"] = DateFormatter.iso8601withWholeSeconds.string(from: startTime)
    }
    if let endTime = endTime {
        extraArgs["end_time"] = DateFormatter.iso8601withWholeSeconds.string(from: endTime)
    }
    
    let parameters = signedParameters(method: method, url: userTimelineURL, credentials: credentials, including: extraArgs)
    userTimelineURL.append(contentsOf: "?\(parameters.parameterString())")
    let url = URL(string: userTimelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    return request
}
