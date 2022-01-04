//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/1/22.
//

import Foundation

/** Shell enum describing the v2 "Friendships/Create" endpoint.
    Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/post-users-source_user_id-following
 */
public enum FriendshipCreateEndpoint {
    
}

fileprivate struct FollowingRequestResponse: Codable {
    let data: FollowingRequestResult
}

public struct FollowingRequestResult: Codable {
    public let following: Bool
    public let pending_follow: Bool
}

public func follow(_ target: String, credentials: OAuthCredentials) async throws -> FollowingRequestResult {
    let request = friendshipCreateRequest(targetID: target, credentials: credentials)
    let body = try JSONEncoder().encode(["target_user_id": target])
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.upload(for: request, from: body, delegate: nil)
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            #if DEBUG
            Swift.debugPrint("Follow request returned with status code \(response.statusCode)")
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            Swift.debugPrint(dict as Any)
            #endif
        }
    }
    
    let blob = try JSONDecoder().decode(FollowingRequestResponse.self, from: data)
    return blob.data
}

/// - Parameters:
///   - userID: Our user's Twitter User ID
///   - targetID: Twitter User ID of the user to follow
///   - credentials: OAuth 1.0 credentials
/// - Returns: URL Request for `userID` to follow `targetID`
fileprivate func friendshipCreateRequest(
    targetID: String,
    credentials: OAuthCredentials
) -> URLRequest {
    authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(credentials.user_id)/following",
        method: .POST,
        credentials: credentials,
        parameters: RequestParameters.empty
    )
}
