//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/1/22.
//

import Foundation

/** Shell enum describing the v2 "Follow" endpoint.
    Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/post-users-source_user_id-following
 */
public enum FollowUserEndpoint {
    
}

fileprivate struct FollowingRequestResponse: Codable {
    let data: FollowingRequestResult
}

public struct FollowingRequestResult: Codable {
    public let following: Bool
    public let pending_follow: Bool
}

public func follow(userID: String, credentials: OAuthCredentials) async throws -> FollowingRequestResult {
    var request = authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(credentials.user_id)/following",
        method: .POST,
        credentials: credentials,
        parameters: RequestParameters.empty
    )
    
    /// To ensure that our request is always sent, ignore local cache data.
    /// Source: https://www.swiftbysundell.com/articles/http-post-and-file-upload-requests-using-urlsession/
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    
    let body = try JSONEncoder().encode(["target_user_id": userID])
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.upload(for: request, from: body, delegate: nil)
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            TwigLog.error("""
                \(#function) returned with bad status code
                - code: \(response.statusCode)
                - dict: \(dict as Any)
                """)
            throw TwigError.badStatusCode(code: response.statusCode)
        }
    }
    
    let blob = try JSONDecoder().decode(FollowingRequestResponse.self, from: data)
    return blob.data
}
