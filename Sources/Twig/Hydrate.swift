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
    let endpoint = "https://api.twitter.com/2/tweets"
    var ids = ids
    if ids.count > 100 {
        Swift.debugPrint("⚠️ WARNING: DISCARDING IDS OVER 100!")
        ids = Array(ids[..<100])
    }
    
    let request = authorizedRequest(
        endpoint: endpoint,
        method: .GET,
        credentials: credentials,
        encoded: [
            TweetExpansion.queryKey: expansions.csv,
            "ids": ids.joined(separator: ","),
            MediaField.queryKey: mediaFields.csv,
            TweetField.queryKey: fields.csv,],
        nonEncoded: [:]
    )
    
    let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)

    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */}
        else {
            Swift.debugPrint("Tweet request returned with status code \(response.statusCode)")
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            Swift.debugPrint(dict as Any)
        }
    }
    
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

internal func authorizedRequest(
    endpoint: String,
    method: HTTPMethod,
    credentials: OAuthCredentials,
    encoded: [String: String?],
    nonEncoded: [String: String?]
) -> URLRequest {
    /// Be extra sure to discard `nil` values.
    var compacted: [String: String] = [:]
    nonEncoded.forEach{ (k,v) in
        if let v = v {
            compacted[k] = v
        }
    }
    
    let parameters = signedParameters(
        method: .GET,
        url: endpoint,
        credentials: credentials,
        encoded: encoded.compacted,
        nonEncoded: nonEncoded.compacted
    )
    
    /// Manually construct query string to avoid percent-encoding CSV commas.
    let queryString = (nonEncoded.isEmpty && encoded.isEmpty)
        ? ""
        : (
            "?"
            + nonEncoded.compacted.keySorted().parameterString()
            + encoded.compacted.encodedSortedParameterString()
        )
    
    Swift.debugPrint(queryString)
    
    let url = URL(string: endpoint + queryString)!
    
    /// Set OAuth authorization header.
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
