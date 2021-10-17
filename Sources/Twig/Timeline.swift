//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public func timeline(credentials: OAuthCredentials) async throws -> [RawTweet] {
    let request = timelineRequest(credentials: credentials)
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    let failables = try! JSONDecoder().decode([Failable<RawTweet>].self, from: data)
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
    
    /// Parameters for an authorization request.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_token": credentials.oauth_token,
        "oauth_version": "1.0",
    ]
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        method: HTTPMethod.GET.rawValue,
        url: timelineURL,
        parameters: parameters,
        consumerSecret: Keys.consumer_secret,
        oauthSecret: credentials.oauth_token_secret
    )
    parameters["oauth_signature"] = signature
    
    /// Formulate request.
    timelineURL.append(contentsOf: "?\(parameters.parameterString())")
    let url = URL(string: timelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    
    return request
}
