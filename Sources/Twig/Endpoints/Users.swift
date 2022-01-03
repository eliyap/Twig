//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 3/1/22.
//

import Foundation

/** Shell enum describing the v2 "Users" endpoint.
    Docs: https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users
 */
public enum UserEndpoint {
    internal static let url = "https://api.twitter.com/2/users"
    
    /// We may request a maximum of 100 users at a time.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/users/lookup/api-reference/get-users
    public static let maxResults = 100
}


public func users(
    userIDs: [String],
    credentials: OAuthCredentials
) async throws {
    precondition(1...100 ~= userIDs.count, "Invalid number of user ids: \(userIDs.count)")
    
    let request = userRequest(userIDs: userIDs, credentials: credentials)
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */}
        else {
            Swift.debugPrint("Users request returned with status code \(response.statusCode)")
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
}

internal func userRequest(
    userIDs: [String],
    credentials: OAuthCredentials
) -> URLRequest {
    authorizedRequest(
        endpoint: UserEndpoint.url,
        method: .GET,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
//            TweetExpansion.queryKey: RawHydratedTweet.expansions.csv,
            "ids": userIDs.joined(separator: ","),
//            TweetField.queryKey: RawHydratedTweet.fields.csv,
//            UserField.queryKey: UserField.common.csv,
        ])
    )
}
