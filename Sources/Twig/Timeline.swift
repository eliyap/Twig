//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public func timeline(credentials: OAuthCredentials) async throws -> Void {
    
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
    
    timelineURL.append(contentsOf: "?\(parameters.parameterString())")
    
    let url = URL(string: timelineURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    
    print(signature)
    
    print(timelineURL)

    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    print(String(data: data, encoding: .ascii))
    print(try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
}
