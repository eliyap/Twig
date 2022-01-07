//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/1/22.
//

import Foundation

fileprivate struct UnfollowRequestResponse: Codable {
    let data: UnfollowRequestResult
}

fileprivate struct UnfollowRequestResult: Codable {
    let following: Bool
}

/// - Returns: whether the user is being followed (should be `false`).
public func unfollow(userID: String, credentials: OAuthCredentials) async throws -> Bool {
    let request = authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(credentials.user_id)/following/\(userID)",
        method: .DELETE,
        credentials: credentials,
        parameters: RequestParameters.empty
    )
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.upload(for: request, from: Data.init(), delegate: nil)
    if let response = response as? HTTPURLResponse {
        if 200..<300 ~= response.statusCode { /* ok! */ }
        else {
            #if DEBUG
            Swift.debugPrint("Unfollow request returned with status code \(response.statusCode)")
            let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            Swift.debugPrint(dict as Any)
            #endif
            throw TwigError.badStatusCode(code: response.statusCode)
        }
    }
    
    let blob = try JSONDecoder().decode(UnfollowRequestResponse.self, from: data)
    return blob.data.following
    
}
