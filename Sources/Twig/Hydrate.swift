//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

public func hydratedTweets(
    credentials: OAuthCredentials,
    ids: [String],
    fields: Set<TweetField> = [],
    expansions: Set<TweetExpansion> = []
) async throws -> ([RawHydratedTweet], [RawIncludeUser]) {
    var ids = ids
    if ids.count > 100 {
        Swift.debugPrint("⚠️ WARNING: DISCARDING IDS OVER 100!")
        ids = Array(ids[..<100])
    }
    
    let request = tweetsRequest(credentials: credentials, ids: ids, fields: fields, expansions: expansions)
    
    let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)

    /// Decode and nil-coalesce.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.iso8601withFractionalSeconds)
    let blob = try decoder.decode(RawHydratedBlob.self, from: data)
    var tweets: [RawHydratedTweet] = (blob.data ?? []).compactMap(\.item)
    tweets += blob.includes?.tweets?.compactMap(\.item) ?? []
    let users: [RawIncludeUser] = blob.includes?.users?.compactMap(\.item) ?? []
    
    return (tweets, users)
}

/// - Note: manual authentication affords us:
///     - non-escaped commas when feeding in id comma separated values,
///     - OAuth as a header, not a query string.
fileprivate func tweetsRequest(
    credentials: OAuthCredentials,
    ids: [String],
    fields: Set<TweetField> = [],
    expansions: Set<TweetExpansion> = []
) -> URLRequest {
    /// Only 100 tweets may be requested at once.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/api-reference/get-tweets
    precondition(ids.count <= 100, "Too many IDs!")
    let idCSV = ids.joined(separator: ",")
    let fieldCSV = fields.map(\.rawValue).joined(separator: ",")
    let expansionCSV = expansions.map(\.rawValue).joined(separator: ",")
    
    var tweetsURL = "https://api.twitter.com/2/tweets"
    
    /// OAuth 1.0 Authroization Parameters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "expansions": expansionCSV,
        "ids": idCSV,
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_token": credentials.oauth_token,
        "oauth_version": "1.0",
        "tweet.fields": fieldCSV,
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

    tweetsURL.append(contentsOf: "?ids=\(idCSV)&tweet.fields=\(fieldCSV)&expansions=\(expansionCSV)")
    
    let url = URL(string: tweetsURL)!
    var request = URLRequest(url: url)
    
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
