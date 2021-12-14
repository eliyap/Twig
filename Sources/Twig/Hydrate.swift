//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

fileprivate let DEBUG_DUMP_JSON = false

public func hydratedTweets(
    credentials: OAuthCredentials,
    ids: [String],
    fields: Set<TweetField> = [],
    expansions: Set<TweetExpansion> = [],
    mediaFields: Set<MediaField> = []
) async throws -> ([RawHydratedTweet], [RawIncludeUser], [RawIncludeMedia]) {
    var ids = ids
    if ids.count > 100 {
        Swift.debugPrint("⚠️ WARNING: DISCARDING IDS OVER 100!")
        ids = Array(ids[..<100])
    }
    
    let request = tweetsRequest(
        credentials: credentials,
        ids: ids,
        fields: fields,
        expansions: expansions,
        mediaFields: mediaFields
    )
    
    let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)

    if DEBUG_DUMP_JSON {
        let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        print(dict as Any)
    }
    
    /// Decode and nil-coalesce.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.iso8601withFractionalSeconds)
    let blob = try decoder.decode(RawHydratedBlob.self, from: data)
    var tweets: [RawHydratedTweet]
    if let data = blob.data {
        tweets = data.compactMap(\.item)
        Swift.debugPrint("All media keys", tweets.compactMap(\.attachments?.media_keys))
    } else {
        Swift.debugPrint("No data returned for hydrated tweets.")
        tweets = []
    }
    tweets += blob.includes?.tweets?.compactMap(\.item) ?? []
    let users: [RawIncludeUser] = blob.includes?.users?.compactMap(\.item) ?? []
    let media: [RawIncludeMedia] = blob.includes?.media?.compactMap(\.item) ?? []
    
    return (tweets, users, media)
}

/// - Note: manual authentication affords us:
///     - non-escaped commas when feeding in id comma separated values,
///     - OAuth as a header, not a query string.
fileprivate func tweetsRequest(
    credentials: OAuthCredentials,
    ids: [String],
    fields: Set<TweetField> = [],
    expansions: Set<TweetExpansion> = [],
    mediaFields: Set<MediaField> = []
) -> URLRequest {
    /// Only 100 tweets may be requested at once.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/api-reference/get-tweets
    precondition(ids.count <= 100, "Too many IDs!")
    let idCSV = ids.joined(separator: ",")
    
    var tweetsURL = "https://api.twitter.com/2/tweets"
    
    let parameters = signedParameters(method: .GET, url: tweetsURL, credentials: credentials, including: [
        TweetExpansion.queryKey: expansions.csv,
        "ids": idCSV,
        MediaField.queryKey: mediaFields.csv,
        TweetField.queryKey: fields.csv,
    ])

    /// Manually construct query string to avoid percent-encoding CSV commas.
    tweetsURL.append(contentsOf: "?ids=\(idCSV)&tweet.fields=\(fields.csv)&expansions=\(expansions.csv)&\(MediaField.queryKey)=\(mediaFields.csv)")
    
    let url = URL(string: tweetsURL)!
    var request = URLRequest(url: url)
    
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}

internal func authorizedRequest(endpoint: String, method: HTTPMethod, credentials: OAuthCredentials, nonEncoded: [String: String]) -> URLRequest {
    let parameters = signedParameters(method: .GET, url: endpoint, credentials: credentials, including: nonEncoded)
    
    /// Manually construct query string to avoid percent-encoding CSV commas.
    let queryString = nonEncoded.isEmpty
        ? ""
        : "?" + nonEncoded.map { (key, value) in "\(key)=\(value)" }.joined(separator: "&")
    
    let url = URL(string: endpoint + "?" + queryString)!
    
    /// Set OAuth authorization header.
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
