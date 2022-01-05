//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/1/22.
//

import Foundation

/** Shell enum describing the v1.1 "Friendships/Create" endpoint.
    Docs: https://developer.twitter.com/en/docs/twitter-api/v1/accounts-and-users/follow-search-get-users/api-reference/post-friendships-create
 */
public enum FriendshipCreateEndpoint {
    internal static let url = "https://api.twitter.com/1.1/friendships/create.json"
}

@available(*, deprecated, message: "Please use v2 follow endpoint instead.")
public func _follow(
    userID: String,
    credentials: OAuthCredentials
) async throws-> Void {
    let request = authorizedRequest(
        endpoint: FriendshipCreateEndpoint.url,
        method: .POST,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            "user_id": userID,
            "follow": "true",
        ])
    )
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.upload(for: request, from: Data.init(), delegate: nil)
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            #if DEBUG
            Swift.debugPrint("Follow request returned with status code \(response.statusCode)")
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            Swift.debugPrint(dict as Any)
            #endif
            throw TwigError.badStatusCode(code: response.statusCode)
        }
    }
    
    print("OK!")
}
