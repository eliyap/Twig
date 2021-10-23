//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/// The additional information we may obtain for a Tweet Object.
/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/tweet
public enum TweetExpansion: String {
    case attachments
    case author_id
    case context_annotations
    case conversation_id
    case created_at
    case entities
    case geo
    case in_reply_to_user_id
    case lang
    case non_public_metrics
    case organic_metrics
    case possibly_sensitive
    case promoted_metrics
    case public_metrics
    case referenced_tweets
    case reply_settings
    case source
    case withheld
}

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

/// - Note: manual authentication affords us:
///     - non-escaped commas when feeding in id comma separated values,
///     - OAuth as a header, not a query string.
fileprivate func tweetsRequest(credentials: OAuthCredentials, ids: [Int]) -> URLRequest {
    /// Only 100 tweets may be requested at once.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/api-reference/get-tweets
    precondition(ids.count <= 100, "Too many IDs!")
    let idCSV = ids.map{"\($0)"}.joined(separator: ",")
    
    var tweetsURL = "https://api.twitter.com/2/tweets"
    
    /// OAuth 1.0 Authroization Parameters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "ids": idCSV,
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_token": credentials.oauth_token,
        "oauth_version": "1.0",
    ]
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        method: HTTPMethod.GET,
        url: tweetsURL,
        parameters: parameters,
        consumerSecret: Keys.consumer_secret,
        oauthSecret: credentials.oauth_token_secret
    )
    parameters["oauth_signature"] = signature

    tweetsURL.append(contentsOf: "?ids=\(idCSV)")
    
    let url = URL(string: tweetsURL)!
    var request = URLRequest(url: url)
    
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
