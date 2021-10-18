//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public func hydratedTweets(credentials: OAuthCredentials, ids: [Int]) async throws -> Void {
    var ids = ids
    if ids.count >= 100 {
        Swift.debugPrint("⚠️ WARNING: DISCARDING IDS OVER 100!")
        ids = Array(ids[..<100])
    }
    
    let request = tweetsRequest(credentials: credentials, ids: ids)
    let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)

    print(try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
}

fileprivate func tweetsRequest(credentials: OAuthCredentials, ids: [Int]) -> URLRequest {
    /// Only 100 tweets may be requested at once.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/api-reference/get-tweets
    precondition(ids.count <= 100, "Too many IDs!")
    
    var tweetsURL = "https://api.twitter.com/2/tweets"
    
    /// OAuth 1.0 Authroization Parameters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ]
    
    parameters["oauth_token"] = credentials.oauth_token
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        method: HTTPMethod.GET.rawValue,
        url: tweetsURL,
        parameters: parameters.merging(["ids": ids.map{"\($0)"}.joined(separator: ",")], uniquingKeysWith: {(curr, _) in curr}),
        consumerSecret: Keys.consumer_secret,
        /**
         > ...where the token secret is not yet known ... the signing key should consist of
         > the percent encoded consumer secret followed by an ampersand character ‘&’.
         – https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
         */
        oauthSecret: credentials.oauth_token_secret
    )
    parameters["oauth_signature"] = signature
    //including: ["id": ids.map{"\($0)"}.joined(separator: ",")]
    tweetsURL.append(contentsOf: "?ids=\(ids.map{"\($0)"}.joined(separator: ","))")
    
    
    print(tweetsURL)
    let url = URL(string: tweetsURL)!
    var request = URLRequest(url: url)
    
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
