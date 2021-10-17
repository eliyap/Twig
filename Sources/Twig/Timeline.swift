//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public func timeline(credentials: OAuthCredentials) async throws -> Void {
    /// Formulate Request.
    let endpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
    let url = URL(string: endpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    
    /// Parameters for an authorization request.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ]
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        url: endpoint,
        parameters: parameters,
        consumerSecret: Keys.consumer_secret,
        oauthSecret: credentials.oauth_token_secret
    )
    parameters["oauth_signature"] = signature
    
    request.setValue(
        "OAuth \(parameters.headerString())",
        forHTTPHeaderField: "Authorization"
    )
    
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    print(try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
}
