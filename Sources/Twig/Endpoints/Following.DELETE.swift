//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/1/22.
//

import Foundation

@available(*, deprecated, message: "Do not use, consistently returns 403 for unknown reason.")
public func _unfollow(_ target: String, credentials: OAuthCredentials) async throws -> Void {
    let request = authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(credentials.user_id)/following/\(target)",
        method: .DELETE,
        credentials: credentials,
        parameters: RequestParameters(encodable: [
            "consumer_key": Keys.consumer,
            "consumer_secret": Keys.consumer_secret,
            "oauth_token": credentials.oauth_token,
            "oauth_token_secret": credentials.oauth_token_secret,
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
    
    /// Never reached.
}
