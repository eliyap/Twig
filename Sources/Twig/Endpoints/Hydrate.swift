//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

/** Shell enum describing the v2 "Tweets" endpoint.
 */
public enum TweetEndpoint {
    internal static let url = "https://api.twitter.com/2/tweets"
    
    /// We may request a maximum of 100 tweets per page.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
    public static let maxResults = 100
}

public func hydratedTweets(
    credentials: OAuthCredentials,
    ids: [String],
    fields: Set<TweetField> = RawHydratedTweet.fields,
    expansions: Set<TweetExpansion> = RawHydratedTweet.expansions,
    mediaFields: Set<MediaField> = RawHydratedTweet.mediaFields
) async throws -> ([RawHydratedTweet], [RawHydratedTweet], [RawUser], [RawIncludeMedia]) {
    let endpoint = "https://api.twitter.com/2/tweets"
    var ids = ids
    if ids.count > TweetEndpoint.maxResults {
        TwigLog.error("DISCARDING IDS OVER \(TweetEndpoint.maxResults)!")
        ids = Array(ids[..<TweetEndpoint.maxResults])
    }
    
    let request = authorizedRequest(
        endpoint: endpoint,
        method: .GET,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            TweetExpansion.queryKey: expansions.csv,
            "ids": ids.joined(separator: ","),
            MediaField.queryKey: mediaFields.csv,
            TweetField.queryKey: fields.csv,
            UserField.queryKey: UserField.common.csv,
        ])
    )
    
    let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)

    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */}
        else {
            TwigLog.error("Tweet request returned with status code \(response.statusCode)")
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            Swift.debugPrint(dict as Any)
        }
    }
    
    /// Decode and nil-coalesce.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.iso8601withFractionalSeconds)
    let blob: RawHydratedBlob
    do {
        blob = try decoder.decode(RawHydratedBlob.self, from: data)
    } catch {
        #if DEBUG
        let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        print(dict as Any)
        #endif
        throw TwigError.malformedJSON
    }
    
    var tweets: [RawHydratedTweet]
    if let data = blob.data {
        tweets = data.compactMap(\.item)
        TwigLog.debug("All media keys: \(tweets.compactMap(\.attachments?.media_keys).flatMap { $0 }.sorted())", print: false, true)
    } else {
        TwigLog.debug("No data returned for hydrated tweets.", print: false, true)
        tweets = []
    }
    let includedTweets = blob.includes?.tweets?.compactMap(\.item) ?? []
    let users: [RawUser] = blob.includes?.users?.compactMap(\.item) ?? []
    let media: [RawIncludeMedia] = blob.includes?.media?.compactMap(\.item) ?? []
    
    return (tweets, includedTweets, users, media)
}

internal func authorizedRequest(
    endpoint: String,
    method: HTTPMethod,
    credentials: OAuthCredentials,
    parameters: RequestParameters
) -> URLRequest {
    let parameterDict = signedParameters(
        method: method,
        url: endpoint,
        credentials: credentials,
        parameters: parameters
    )
    
    let url = URL(string: endpoint + parameters.queryString())!
    
    /// Set OAuth authorization header.
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("OAuth \(parameterDict.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
